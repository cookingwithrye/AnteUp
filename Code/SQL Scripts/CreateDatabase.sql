--creates the database tables MINUS the relationships per conventions in this project
BEGIN TRANSACTION CreateDatabaseTables

--user authentication information
--TODO: direct authentication through some kind of shared account (google, facebook, etc.)
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
	
	--settings for this profile
	--TODO: add settings that control whether/how the user wants to receive notifications etc.
);

COMMIT TRANSACTION CreateDatabaseTables

--create relationships between tables
BEGIN TRANSACTION CreateRelations

ALTER TABLE User ADD FOREIGN KEY ProfileID REFERENCES Profile(ProfileID); --users have profiles

COMMIT TRANSACTION CreateRelations

--add default values to the database
BEGIN TRANSACTION CreateDefaults

--TODO: check for the presence of defaults already in the database
INSERT INTO ContactMethod (

COMMIT TRANSACTION CreateDefaults