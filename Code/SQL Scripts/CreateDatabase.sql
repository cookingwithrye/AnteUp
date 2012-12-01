--creates the database tables MINUS the relationships per conventions in this project, they are created in a separate transaction
BEGIN TRANSACTION CreateDatabaseTables

--user authentication information
--TODO: direct authentication through some kind of shared account (google, facebook, etc.) using OAuth
CREATE TABLE User (
	UserID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	InActive BIT NOT NULL DEFAULT 0,
	
	WhenCreated DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	WhenActivated DATETIME DEFAULT NULL,
	HashedPassword NVARCHAR(50) DEFAULT NULL,
	
	UnSuccessfulLoginAttemptCount INT NOT NULL DEFAULT 0,
	
	ProfileID INT NOT NULL --FOREIGN KEY REFERENCES Profile(ProfileID)
);
 
--user profile information
--TODO: upgrade to allow to be pulled in from a linked source such as google or facebook account)
CREATE TABLE Profile (
	ProfileID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	
	Firstname NVARCHAR(50) DEFAULT NULL,
	Lastname NVARCHAR(50) DEFAULT NULL,
	
	--contact information for this profile (future use for automatic notifications)
	Email NVARCHAR(200) DEFAULT NULL,
	Phone NVARCHAR(15) DEFAULT NULL,
	TwitterHandle NVARCHAR(100) DEFAULT NULL,
	GoogleAccount NVARCHAR(100) DEFAULT NULL,
	Facebook NVARCHAR(100) DEFAULT NULL
	
	--TODO: add settings that control whether/how the user wants to receive notifications etc.
);

--a household/shared grouping of transactions and users
CREATE TABLE Household (
	HouseID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	
	Name NVARCHAR(50),	--name of this household
);

--a tenant that is part of a household
CREATE TABLE Tenant (
	TenantID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	
	HouseID INT NOT NULL,
	UserID INT NOT NULL,
	
	IsDeleted BIT NOT NULL DEFAULT 0,
);

--transactions between users for money
CREATE TABLE Transaction (
	TransactionID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	
	HouseID INT NOT NULL,		--the house that this transaction is for
	Amount SMALLMONEY NOT NULL, --how much is this transaction/bill for?
	
	IsDeleted BIT NOT NULL DEFAULT 0,
);

--which users are involved in a transaction
CREATE TABLE TransactionInvolvement (
	TransactionID INT NOT NULL,
	UserID INT NOT NULL,
	Percentage INT NOT NULL, --how much of this transaction is this user responsible for?
	Paid SMALLMONEY NOT NULL, --how much did this user actually pay so far? Can exceed their required share
);

--records all history of changes for a given transaction
CREATE TABLE TransactionHistory (
	TransactionHistoryID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	
	TransactionID INT NOT NULL,
	ChangeComment NVARCHAR(MAX) NOT NULL,	--what changed in a transaction? e.g. 'Amount of hydro bill ID#444 was updated from $80 to $90.'
	
	WhoModified INT NOT NULL,		--which user modified this transaction?
);

--organization for objects in the system
CREATE TABLE Tag (
	TagID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	
	Name NVARCHAR(50) NOT NULL,
	ParentTagID INT DEFAULT NULL,
	
	IsCategory BIT NOT NULL DEFAULT 0,		--is this tag a category item?
);

COMMIT TRANSACTION CreateDatabaseTables

--create relationships between tables
BEGIN TRANSACTION CreateRelations

ALTER TABLE User ADD FOREIGN KEY ProfileID REFERENCES Profile(ProfileID); --users have profiles

ALTER TABLE Transaction ADD FOREIGN KEY HouseID REFERENCES Household(HouseID); --transactions belong to houses
ALTER TABLE Tenant ADD FOREIGN KEY HouseID REFERENCES Household(HouseID);	--houses have tenants
ALTER TABLE Tenant ADD FOREIGN KEY UserID REFERENCES User(UserID);			--tenants must be users in the system

ALTER TABLE TransactionInvolvement ADD FOREIGN KEY TransactionID REFERENCES Transaction(TransactionID);
ALTER TABLE TransactionInvolvement ADD FOREIGN KEY UserID REFERENCES User(UserID); --transactions involve users

ALTER TABLE TransactionHistory ADD FOREIGN KEY TransactionID REFERENCES Transaction(TransactionID); --transaction modifications are attached to specific transactions
ALTER TABLE TransactionHistory ADD FOREIGN KEY WhoModified REFERENCES User(UserID);

ALTER TABLE Tag ADD FOREIGN KEY ParentTagID REFERENCES Tag(TagID);	--tags can have parent tags
 
COMMIT TRANSACTION CreateRelations

--add default values to the database
BEGIN TRANSACTION CreateDefaults

COMMIT TRANSACTION CreateDefaults