/*
.SYNOPSIS
    DBAdmin Database Creation Script
.DESCRIPTION
   Creates DBAdmin Database to store tools for Database Administration and other Database Server related informations
   Creates DBAdmin database on default data and log folder.
   Sets REcovery Model to SIMPLE
   Sets Database Owner to SA
.NOTES
    Author: Deepam Ghosh
    Version: 1.0
*/



USE master

--ASSIGN A VALUE TO THE BELOW VARIABLES  AS REQUIRED

DECLARE @dbname nvarchar(50) = 'DBAdmin'  --Database Name
DECLARE @nologfile nvarchar(10) = 1	 -- Number of Primary Log file
DECLARE @datafilesize nvarchar(255) = '1024MB'
DECLARE @datafilegrowth nvarchar(255) = '500MB'
DECLARE @logfilesize nvarchar(255) = '500MB'
DECLARE @logfilegrowth nvarchar(255) = '500MB'

DECLARE @sql nvarchar(max)

/*
	Checking if Database already exists
*/

IF EXISTS(SELECT 1 FROM SYS.DATABASES WHERE NAME = @dbname)
GOTO DBEXISTS

DECLARE @defaultdatapath nvarchar(max) = convert(nvarchar(max),(select SERVERPROPERTY('InstanceDefaultDataPath')))  --Default Data Directory
DECLARE @defaultlogpath nvarchar(max) =  convert(nvarchar(max),(select SERVERPROPERTY('InstanceDefaultLogPath')))   --Default Log Directory

--PRINT 'Default Data Directory -----> ' + @defaultdatapath
--PRINT 'Default Log Directory -----> ' + @defaultlogpath


DECLARE @primarydatafilelocation nvarchar(255) = @defaultdatapath + @dbname + '_Data.mdf'  -- Primary Data File location
DECLARE @logfilelocation nvarchar(255) = @defaultlogpath + @dbname + '_Log.ldf'  -- Primary Log file location




/* 
	Creating Database.........
*/
SET @sql = 'CREATE DATABASE ' + QUOTENAME(@dbname)  + ' ON PRIMARY ( NAME = ' + QUOTENAME(@dbname + '_Data') + ' , FILENAME = ''' + @primarydatafilelocation + ''', SIZE = ' + @datafilesize + ', 
			MAXSIZE = UNLIMITED, FILEGROWTH = ' + @datafilegrowth + ') 
			LOG ON (NAME = ' + QUOTENAME(@dbname + '_Log') + ', FILENAME = ''' + @logfilelocation + ''', SIZE = ' + @logfilesize + ', MAXSIZE = UNLIMITED, FILEGROWTH = ' + @logfilegrowth + ')'

RAISERROR('Creating Database DBAdmin.....',0,0)
--WAITFOR DELAY '00:00:05'

BEGIN TRY
	EXEC (@sql)
	--PRINT (@sql)
	RAISERROR('Database %s Created Successfully!',0,0,@dbname)

	--WAITFOR DELAY '00:00:02'
	RAISERROR('Primary Data File Location - %s',0,0,@primarydatafilelocation)
	RAISERROR('Log File Location - %s',0,0,@logfilelocation)
	RAISERROR('Initial DataFile Size - ',0,0,@datafilesize)
	RAISERROR('Data FileGrowth - %s',0,0,@datafilegrowth)
	RAISERROR('Initial LogFile Size - %s',0,0,@logfilesize)
	RAISERROR('Log FileGrowth - %s',0,0,@logfilegrowth)

END TRY

BEGIN CATCH
	RAISERROR('Database Creation Failed...!!!!!',11,1)
END CATCH

/*
	SET RECOVERY MODEL TO SIMPLE 
*/
SET @sql = 'USE '  + QUOTENAME(DB_NAME(1)) + '
	ALTER DATABASE ' + QUOTENAME(@dbname) + ' SET RECOVERY SIMPLE WITH NO_WAIT 
	'
EXEC (@sql)
RAISERROR('Recovery Model for Database %s Set to SIMPLE',0,0,@dbname)
	--WAITFOR DELAY '00:00:02'
	

/*
	Changing Database Owner to SA
*/

SET @sql = 'USE ' + QUOTENAME(@dbname) + ' 
ALTER AUTHORIZATION ON DATABASE::' + QUOTENAME(@dbname) + ' TO [sa]'
EXEC (@sql)
RAISERROR('Owner of Database %s Changed to SA',0,0,@dbname)

GOTO LAST	

DBEXISTS:
RAISERROR('Database %s Already Exists....Please DROP the Database to create it again.',11,1,@dbname)


LAST:
PRINT ''