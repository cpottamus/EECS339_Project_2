#!/usr/bin/perl -w

use strict;

use CGI qw(:standard);
use CGI::Cookie;
use DBI;

use HTML::Template;

my $debug = 0;

my @sqlinput = ();
my @sqloutput = ();

my $dbuser = 'mjg839';
my $dbpasswd = 'zdu5GU1to';

# state variables
my $loggedin = 0;
my $pfname = param('pfname');
my $username = '';
my @pfid = ();
my $pid = undef;


# open the HTML Template
my $toolbarTemplate = HTML::Template->new(filename => 'toolbar.tmpl');
my $baseTemplate = HTML::Template->new(filename => 'home.tmpl', die_on_bad_params => 0);
my $overviewTemplate = HTML::Template->new(filename => 'overview.tmpl');
my $registerTemplate = HTML::Template->new(filename => 'register.tmpl', die_on_bad_params => 0);
my $registerConfirmTemplate = HTML::Template->new(filename => 'registerconfirm.tmpl', die_on_bad_params => 0);
my $stocklistTemplate = HTML::Template->new(filename => 'stocklist.tmpl', global_vars => 1);
my $tradingStrategyTemplate = HTML::Template->new(filename => 'tradingStrategy.tmpl', die_on_bad_params => 0);
my $singleStockTemplate = HTML::Template->new(filename => 'singleStock.tmpl');
my $stockStatTemplate = HTML::Template->new(filename => 'stat.tmpl');
my $createPortfolioTemplate = HTML::Template->new(filename => 'createportfolio.tmpl', die_on_bad_params => 0);

#
# Get the user action and whether he just wants the form or wants us to
# run the form
#
my $action;
my $run;
my $cookie = undef;
parse_cookie();

if (defined(param("act"))) { 
  $action=param("act");
  if (defined(param("run"))) { 
    $run = param("run") == 1;
  } else {
    $run = 0;
  }
} else {
  $action="base";
  $run = 1;
}

# Handle actions
if ($action eq 'login') {
        my @userdata = eval { ExecSQL($dbuser,$dbpasswd,"select * from users where username=? and password=?",undef,param('user'),param('pwd')); };
                if ($#userdata != -1) {
                $loggedin = 1;
                $username = ${$userdata[0]}[0];

                set_generic_params($baseTemplate);
                # bake the updated cookie and render template
                bake_cookie();
                $baseTemplate->param(LOGGEDIN => $loggedin);
                print $baseTemplate->output;
                } else {
                                bake_cookie();
                                print "<html><body>Sorry. Those credentials were not recognized, please try again.</body></html>";
                        }
} elsif ($action eq 'logout') {
                $loggedin = 0;
                # bake the updated cookie and render template
                bake_cookie();
                $baseTemplate->param(LOGGEDIN => $loggedin);
                # print template output
                print $baseTemplate->output;
} elsif ($action eq 'base') {
                # bake the updated cookie and render template
                set_generic_params($baseTemplate);
                bake_cookie();
                print $baseTemplate->output;
}elsif ($action eq 'register') {
                set_generic_params($registerTemplate);
                $registerTemplate->param(LOGGEDIN => 0);
                bake_cookie();
        if ($run == 0) {
                        $registerTemplate->param(registered => 0);
            print $registerTemplate->output;
        } else {
                        user_invite(param('email'),param('username'),param('pwd'));
                        $registerTemplate->param(registered => 1);
            print $registerTemplate->output;
        }
} elsif ($action eq 'register_confirm') {
                set_generic_params($registerConfirmTemplate);
                bake_cookie();
                
                my @users = eval { ExecSQL($dbuser,$dbpasswd,
                        "select * from users where name=?",undef,param('user'));
                };
                if ($#users == -1) {
                        eval { ExecSQL($dbuser,$dbpasswd,"insert into users (username,password) values (?,?)",undef,param('user'),param('pwd')); };
                        $registerConfirmTemplate->param(success => 1);
                } else {
                        $registerConfirmTemplate->param(success => 0);
                }
                
                print $registerConfirmTemplate->output;
}# all of these actions should only be processed if the user is logged in
elsif ($loggedin == 1) {
        if ($action eq 'createNewPortfolio') {
			set_generic_params($createPortfolioTemplate);
			if ($run == 1) {
				my $newPfName = param('newpfname');
				my $initialCashAmnt = param('initcash');
				
				my @portfolioData = eval { ExecSQL($dbuser,$dbpasswd,"select * from portfolios where owner=? and name=?",undef,$username,$newPfName); };
				
				my $createsuccess = ($#portfolioData == -1); # can only create new portfolio if it doesn't exist already
				
				if ($createsuccess == 1) {
					eval { ExecSQL($dbuser,$dbpasswd,"insert into portfolios (pid,name,owner) values (pid_count.nextval,?,?)",undef,$newPfName,$username); };
					
					eval { ExecSQL($dbuser,$dbpasswd,"insert into cash_accts (amount,owner,portfolio) values (?,?,pid_count.nextval - 1)",undef,$initialCashAmnt,$username); };
				}
				
				$createPortfolioTemplate->param(success => $createsuccess,
												run => 1);
				
				bake_cookie();
				print $createPortfolioTemplate->output;
			} else {
				$createPortfolioTemplate->param(run => 0);
                bake_cookie();
                print $createPortfolioTemplate->output;
			}
        } elsif (($action eq 'overview') or ($action eq 'depositOrWithdrawCash')) {
                        ## TODO: dynamically populate this info based on DB info
                        set_generic_params($overviewTemplate);
						$pid = get_current_pid();
                        #Get parameters for pageview
                        my @currentAmount = eval { ExecSQL($dbuser, $dbpasswd, "SELECT amount FROM cash_accts WHERE owner = ? AND portfolio = ?", "COL", $username, $pid);};
                        
                        #TODO::: logic to calculate portfolio value, average volatility, and correlation

                        $overviewTemplate->param(
                                CASH_IN_ACCT => $currentAmount[0],
                                PORTFOLIO_VAL => 10000,
                                PORTFOLIO_AVG_VOL => 0.5,
                                PORTFOLIO_AVG_CORR => 0.8
                        );
                        if ($action eq 'overview') {
                                # bake the updated cookie and render template
                                bake_cookie();
                                print $overviewTemplate->output;
                        }
                        elsif ($action eq 'depositOrWithdrawCash') {
                                my $amount = param('bankAmount');
                                if (param('type') eq 'deposit') {
                                        #continue;
                                                eval { ExecSQL($dbuser, $dbpasswd, "UPDATE cash_accts SET amount = amount + ? WHERE owner = ? AND portfolio = ?", undef, $amount, $username, $pid);};
                                } elsif (param('type') eq 'withdraw') {
                                        #continue;
                                                if($amount < $currentAmount[0]){
                                                    print "<script> alert('This will overdraw your account, transaction not possible');</script>";
                                                }else{
                                                  eval { ExecSQL($dbuser, $dbpasswd, "UPDATE cash_accts SET amount = amount - ? WHERE owner = ? AND portfolio = ?", undef, $amount, $username, $pid);};
                                                }
                                }             
                                bake_cookie();
                                
                                my @cash = eval { ExecSQL($dbuser, $dbpasswd, "SELECT amount FROM cash_accts WHERE owner = ? AND portfolio = ?", "COL", $username, $pid);};
                                $overviewTemplate->param(CASH_IN_ACCT => $cash[0]);
                                print $overviewTemplate->output;
                        }
        } elsif ($action eq 'viewStockList') {
			set_generic_params($stocklistTemplate);

                  #Action items:

                  #TODO: Param(type)'s for  adding a stock,
                  #TODO: Param(type)'s for  buying a stock,
                  #TODO: Param(type)'s for  selling a stock,

                  #TODO: See make_stock_hash for list.
			$stocklistTemplate->param(STOCK_INFO => make_stock_hash());
			bake_cookie();
			print $stocklistTemplate->output;
	  } elsif ($action eq 'tradingStrategy') {
			set_generic_params($tradingStrategyTemplate);
			bake_cookie();
			print $tradingStrategyTemplate->output;
	  } elsif (($action eq 'stockStats') or ($action eq 'stockHistory')) {
			$pfname = param('pfname');
			my $symbolName = param('symbol');
			if ($action eq 'stockStats') {
				set_generic_params($stockStatTemplate);
				
                        #TODO: param(date)'s for selecting time interval
                                      #-pass total calculated beta in params,
                                      #-pass hash of each coefficient of variation & beta estimate for every stock.
                                      #-pass matrix hash for matrix generation.


                        bake_cookie();
				print $stockStatTemplate->output;
			} else { # stockHistory
				set_generic_params($singleStockTemplate);

                      #TODO: make a param hash makeStockHistory, this will contain all of the historical/current data for a stock, for use in JS graph creation.

                      #TODO: call trading strategy and pass the stuff to param to generate predicted value chart 
				$singleStockTemplate->param(cur_ss => $symbolName);
				bake_cookie();
				print $singleStockTemplate->output;
			}
			
		}
} else {
                bake_cookie();
                print $baseTemplate->output;
}

# The following is necessary so that DBD::Oracle can
# find its butt
#
BEGIN {
  unless ($ENV{BEGIN_BLOCK}) {
    use Cwd;
    $ENV{ORACLE_BASE}="/raid/oracle11g/app/oracle/product/11.2.0.1.0";
    $ENV{ORACLE_HOME}=$ENV{ORACLE_BASE}."/db_1";
    $ENV{ORACLE_SID}="CS339";
    $ENV{LD_LIBRARY_PATH}=$ENV{ORACLE_HOME}."/lib";
    $ENV{BEGIN_BLOCK} = 1;
    exec 'env',cwd().'/'.$0,@ARGV;
  }
}

###################
### SUBROUTINES ###
###################

# Not ideal: we have to manually make sure parameters are retrieved in the parse function in the same order that they were stored in bake...
sub parse_cookie {
        my %cookies = CGI::Cookie->fetch;
    my $cookie = $cookies{'NUPortfolioCookie'};
    if ($cookie) {
                ($loggedin,$username) = split(/\//,$cookie->value);
        }
}

sub bake_cookie {
        $cookie = CGI::Cookie->new(-name=>'NUPortfolioCookie',-value=>"$loggedin/$username");
        $cookie->bake;
}

#
# @list=ExecSQL($user, $password, $querystring, $type, @fill);
#
# Executes a SQL statement.  If $type is "ROW", returns first row in list
# if $type is "COL" returns first column.  Otherwise, returns
# the whole result table as a list of references to row lists.
# @fill are the fillers for positional parameters in $querystring
#
# ExecSQL executes "die" on failure.
#
sub ExecSQL {
  my ($user, $passwd, $querystring, $type, @fill) =@_;
  if ($debug) { 
    # if we are recording inputs, just push the query string and fill list onto the 
    # global sqlinput list
    push @sqlinput, "$querystring (".join(",",map {"'$_'"} @fill).")";
  }
  my $dbh = DBI->connect("DBI:Oracle:",$user,$passwd);
  if (not $dbh) { 
    # if the connect failed, record the reason to the sqloutput list (if set)
    # and then die.
    if ($debug) { 
      push @sqloutput, "<b>ERROR: Can't connect to the database because of ".$DBI::errstr."</b>";
    }
    die "Can't connect to database because of ".$DBI::errstr;
  }
  my $sth = $dbh->prepare($querystring);
  if (not $sth) { 
    #
    # If prepare failed, then record reason to sqloutput and then die
    #
    if ($debug) { 
      push @sqloutput, "<b>ERROR: Can't prepare '$querystring' because of ".$DBI::errstr."</b>";
    }
    my $errstr="Can't prepare $querystring because of ".$DBI::errstr;
    $dbh->disconnect();
    die $errstr;
  }
  if (not $sth->execute(@fill)) { 
    #
    # if exec failed, record to sqlout and die.
    if ($debug) { 
      push @sqloutput, "<b>ERROR: Can't execute '$querystring' with fill (".join(",",map {"'$_'"} @fill).") because of ".$DBI::errstr."</b>";
    }
    my $errstr="Can't execute $querystring with fill (".join(",",map {"'$_'"} @fill).") because of ".$DBI::errstr;
    $dbh->disconnect();
    die $errstr;
  }
  #
  # The rest assumes that the data will be forthcoming.
  #
  #
  my @data;
  if (defined $type and $type eq "ROW") { 
    @data=$sth->fetchrow_array();
    $sth->finish();
    if ($debug) {push @sqloutput, MakeTable("debug_sqloutput","ROW",undef,@data);}
    $dbh->disconnect();
    return @data;
  }
  my @ret;
  while (@data=$sth->fetchrow_array()) {
    push @ret, [@data];
  }
  if (defined $type and $type eq "COL") { 
    @data = map {$_->[0]} @ret;
    $sth->finish();
    if ($debug) {push @sqloutput, MakeTable("debug_sqloutput","COL",undef,@data);}
    $dbh->disconnect();
    return @data;
  }
  $sth->finish();
  if ($debug) {push @sqloutput, MakeTable("debug_sql_output","2D",undef,@ret);}
  $dbh->disconnect();
  return @ret;
}

sub make_stock_hash {

      #TODO :: Generate stock hash in appropriate data form for query. Pass into param

	return [
		{symbol => 'GOOG', timestamp => '1/1/72', openval => '1000', high => '1250', low => '750', closeval => '1300', volume => '800' },
		{symbol => 'GOOG', timestamp => '1/1/72', openval => '1000', high => '1250', low => '750', closeval => '1300', volume => '800' },
		{symbol => 'GOOG', timestamp => '1/1/72', openval => '1000', high => '1250', low => '750', closeval => '1300', volume => '800' },
	];
}

sub set_generic_params {
	
	my @pfnames = eval { ExecSQL($dbuser,$dbpasswd,"select name from portfolios where owner = ?",'COL',$username); };	

	my @pfdata = ();
	
	foreach (@pfnames) {
		push(@pfdata,{	name => "$_",
						overviewlink => "portfolio.pl?act=overview&pfname=$_"} );
	}
	
	my ($template) = @_;
	
	$template->param(	LOGGEDIN => $loggedin,
                        USERNAME => $username,

						PORTFOLIO_NAMES => \@pfdata,
						TRADING_STRATEGIES => [
							{		name => 'Shannon Rachet' },
							{ 		name => 'myStrat_B' }
						],
						CUR_PORTFOLIO => $pfname,
                     );
}

sub user_invite {
        
        my ($email,$user,$pwd) = @_;
        
        #
        #creating unique link
        #
        my $link = "http://murphy.wot.eecs.northwestern.edu/~mjg839/portfolio/portfolio.pl?act=register_confirm&run=1&user=$user&pwd=$pwd";
        
        # creating email text
        my $subject = "New-Portfolio-Account";
        my $content = "Click the link below to setup your account. \n\n\n $link";
        
        
        #
        # This is the magic.  It means "run mail -s ..." and let me 
        # write to its input, which I will call MAIL:
        #
        open(MAIL,"| mail -s $subject $email") or die "Can't run mail\n";
        #
        # And here we write to it
        #
        print MAIL $content;
        #
        # And then close it, resulting in the email being sent
        #
        close(MAIL);                                
}

sub get_current_pid {
	@pfid = eval {ExecSQL($dbuser, $dbpasswd, "select pid from portfolios where name=? and owner=?", "COL", $pfname, $username);};
	return $pfid[0];	
}
