#!/usr/bin/perl -w

use strict;

use CGI qw(:standard);
use CGI::Cookie;
use DBI;

use HTML::Template;

my $debug = 0;

my @sqlinput = ();
my @sqloutput = ();

# state variables
my $loggedin = 0;
my $username = 'Moritz';



# open the HTML Template
my $baseTemplate = HTML::Template->new(filename => 'home.tmpl');
#my $portfolioTemplate = HTML::Template->new(filename => 'porfolio.tmpl');

parse_cookie();

#
# Get the user action and whether he just wants the form or wants us to
# run the form
#
my $action;
my $run;
my $cookie = undef;

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

# set template parameters
$baseTemplate->param(
	LOGGEDIN => $loggedin,
	USERNAME => $username,
	PORTFOLIO_NAMES => [ 
                           { name => 'conservative'},
					       { name => 'myPortfolio' },
                       ]
);

# bake the updated cookie right before we display the HTML
bake_cookie();

# Handle actions
if ($action eq 'login') {
		$loggedin = 1;
		# print template output
		print $baseTemplate->output;
} elsif ($action eq 'logout') {
		$loggedin = 0;
		$baseTemplate->param(LOGGEDIN => $loggedin);
		# print template output
		print $baseTemplate->output;
} elsif ($action eq 'base') {
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
		my @kvpairs = split('/&/',$cookie->value);
		$loggedin = ${kvpairs[0]};
	}
}

sub bake_cookie {
	$cookie = CGI::Cookie->new(-name=>'NUPortfolioCookie',-value=>"$loggedin&");
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
