-- Create Users table (and insert Root as a user)
create table users (
	username 		varchar(255) not null primary key,
	password 		varchar(255) not null
);

insert into users (username, password) values ('root', 'rootroot');

-- Create portfolios table (and a portfolio for Root); create autoincrement for pid

CREATE TABLE portfolios (
	pid				number NOT NULL PRIMARY KEY,
	name			varchar(255),
	owner			varchar(255) NOT NULL REFERENCES users(username) ON DELETE CASCADE
);

INSERT INTO portfolios VALUES (pid_count.nextval,'initialPortfolio', 'root');

-- Autoincrement pid
CREATE SEQUENCE pid_count START WITH 1 INCREMENT BY 1 CACHE 100;

-- Create Stocks table

CREATE TABLE stocks (
	symbol			varchar(5) NOT NULL,
	portfolio		number NOT NULL REFERENCES portfolios(pid) ON DELETE CASCADE,
	quantity		number NOT NULL,
	PRIMARY KEY(symbol,portfolio)
);

-- Create Cash Accounts table

CREATE TABLE cash_accts (
	amount			number NOT NULL,
	owner			varchar(255) NOT NULL REFERENCES users(username) ON DELETE CASCADE,
	portfolio		number NOT NULL REFERENCES portfolios(pid) ON DELETE CASCADE,
	PRIMARY KEY(owner, portfolio)
);

-- Create New Stocks table

CREATE TABLE stocks_new (
	symbol			varchar(16) NOT NULL,
	timestamp		number NOT NULL,
	open			number NOT NULL,
	high			number NOT NULL,
	low				number NOT NULL,
	close			number NOT NULL,
	volume			number NOT NULL,
	PRIMARY KEY(symbol, timestamp)
);

-- Create New Beta Data Table

CREATE TABLE beta_data(
	timestamp		number NOT NULL,
	close			number NOT NULL
);

quit;
