/*
.SYNOPSIS
    SQL Server Database Mail Configuration Script
.DESCRIPTION
    1.Setup SQL Server SMTP Account 
	2.Setup DatabaseMail Profile
.NOTES
    Author: Deepam Ghosh
    Version: 1.0
*/

EXEC sp_configure 'show advanced options', 1
GO
RECONFIGURE WITH OVERRIDE
GO
EXEC sp_configure 'Database Mail XPs', 1
GO
RECONFIGURE WITH OVERRIDE
GO
EXEC sp_configure 'show advanced options', 0
GO
RECONFIGURE WITH OVERRIDE
GO


----------------------------------------------------

--		DatabaseMail Account Setup

----------------------------------------------------

DECLARE 
@DBMailAccountName sysname ='SQLMail',   --Define DBMail Account Name
@SMTPServername sysname = 'smtp.example.com',		--Define SMTP HostName
@emailAddress NVARCHAR(128) = 'noreply@example.com', --Define Sender EmailID
@displayName NVARCHAR(128) = '',	--Define Email Display Name
@replyToAddress NVARCHAR(128)='noreply@example.com',	--Define ReplyTo EmailID
@port INT=587,						--Define SMTP Port
@username NVARCHAR(128)='SMTPUSERNAME',			--Define SMTP UserName
@password NVARCHAR(128)='SMTPPASSWORD',			--Define SMTP Password
@profileName sysname = 'PROFILENAME',		--Define DBMail Profile Name
@profileDescription NVARCHAR(128) = 'Profile Used For Adminitrative Purposes'  --Define DBMail Profile Desc


-- Verify the specified account and profile do not already exist.
IF EXISTS (SELECT * FROM msdb.dbo.sysmail_account WHERE name = @DBMailAccountName )
BEGIN
 RAISERROR('DatabaseMail Account %s Already Exists.', 11, 1, @DBMailAccountName) WITH NOWAIT;
 GOTO done;
END;

-- Start a transaction before adding the account 
BEGIN TRANSACTION ;

DECLARE @rv INT;

-- Add the account
EXECUTE @rv=msdb.dbo.sysmail_add_account_sp
    @account_name = @DBMailAccountName,
    @email_address = @emailAddress,
    @display_name = @displayName,
    @mailserver_name = @SMTPServername,
    @replyto_address = @replyToAddress,
	@port = @port,
	@username = @username,
	@password = @password,
	@enable_ssl = 1

IF @rv<>0
BEGIN
    RAISERROR('DatabaseMail Account %s Creation Failed.', 11, 1, @DBMailAccountName) WITH NOWAIT;
    GOTO done;
END
ELSE
	RAISERROR('DatabaseMail Account %s Created Successfully.',0,0,@DBMailAccountName) WITH NOWAIT;

COMMIT TRANSACTION;


----------------------------------------------------

--		DatabaseMail Profile Setup

----------------------------------------------------

-- Verify the specified account and profile do not already exist.
IF EXISTS (SELECT * FROM msdb.dbo.sysmail_profile WHERE name = @profileName)
BEGIN
  RAISERROR('DatabaseMail Profile %s Already Exists.', 11, 1, @profileName) WITH NOWAIT;
  GOTO done;
END;

BEGIN TRANSACTION ;

-- Add the profile
EXECUTE @rv=msdb.dbo.sysmail_add_profile_sp
    @profile_name = @profileName,
	@description =  @profileDescription;

IF @rv<>0
BEGIN
    RAISERROR('DatabaseMail Profile %s Creation Failed.', 11, 1, @profileName) WITH NOWAIT;
    ROLLBACK TRANSACTION;
    GOTO done;
END
ELSE
	RAISERROR('DatabaseMail Profile %s Created Successfully!',0,1,@profileName) WITH NOWAIT

-- Associate the account with the profile.
EXECUTE @rv=msdb.dbo.sysmail_add_profileaccount_sp
    @profile_name = @profileName,
    @account_name = @DBMailAccountName,
	@sequence_number = 1 ;

IF @rv<>0
BEGIN
    RAISERROR('Failed.DatabaseMail Profile %s could not be mapped to DatabaseMail Account %s',11,1,@profileName,@DBMailAccountName) ;
    ROLLBACK TRANSACTION;
    GOTO done;
END
ELSE
	RAISERROR('DatabaseMail Profile %s mapped to DatabaseMail Account %s',0,1,@profileName,@DBMailAccountName) WITH NOWAIT



--==========================================================
-- Test Database Mail
--==========================================================
DECLARE @sub VARCHAR(100)
DECLARE @body_text NVARCHAR(MAX)
SELECT @sub = 'Test from New SQL install on ' + @@servername
SELECT @body_text = N'This is a test of Database Mail.' + CHAR(13) + CHAR(13) + 'SQL Server Version Info: ' + CAST(@@version AS VARCHAR(500))

EXEC msdb.dbo.[sp_send_dbmail] 
      @profile_name = @profileName
	, @recipients = 'user@example.com'
	, @subject = @sub
	, @body = @body_text


--================================================================
-- SQL Agent Properties Configuration
--================================================================
EXEC msdb.dbo.sp_set_sqlagent_properties 
	  @databasemail_profile = @DBMailAccountName
	, @use_databasemail=1

COMMIT TRANSACTION;

done:

GO

