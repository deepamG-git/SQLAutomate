/*
.SYNOPSIS
    SQL Server ServerLevel Trigger Configuration Script
.DESCRIPTION
    Setup Server Level Triggers to Track ALTER DATABASE AND DROP DATABASE SQL Statements 
.NOTES
    Author: Deepam Ghosh
    Version: 1.0
*/

USE [master];
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- Drop the trigger if it already exists
IF EXISTS (SELECT * FROM sys.server_triggers WHERE name = 'Trig_Prevent_Drop_Database')
BEGIN
    RAISERROR('Trigger ''Trig_Prevent_Drop_Database'' already exists. Dropping it now...',0,0) WITH NOWAIT;
    DROP TRIGGER [Trig_Prevent_Drop_Database] ON ALL SERVER;
END
GO

-- Create the trigger
--PRINT 'Creating trigger ''Trig_Prevent_Drop_Database''...';
EXEC ('CREATE TRIGGER [Trig_Prevent_Drop_Database]
ON ALL SERVER
FOR DROP_DATABASE
AS
BEGIN
   
   
    BEGIN
        RAISERROR(''Dropping of databases has been disabled on this server.'', 16, 1);
        ROLLBACK;
    END
END');
GO

-- Verify that the trigger was created
IF EXISTS (SELECT * FROM sys.server_triggers WHERE name = 'Trig_Prevent_Drop_Database')
    RAISERROR('Trigger ''Trig_Prevent_Drop_Database'' Created.',0,0) WITH NOWAIT;
ELSE
    RAISERROR('Failed to create trigger ''Trig_Prevent_Drop_Database''.',11,1) WITH NOWAIT;
GO
