/*
.SYNOPSIS
    SQL Server Alerts Configuration Script
.DESCRIPTION
    Setup following alerts-
		('1480' , 'AG Role Change (failover)') , ('976'  , 'Database Not Accessible') , ('983'  , 'Database Role Resolving')
      , ('3402' , 'Database Restoring') , ('19406', 'AG Replica Changed States')  , ('35206', 'Connection Timeout')
      , ('35250', 'Connection to Primary Inactive')  , ('35264', 'Data Movement Suspended')  , ('35273', 'Database Inaccessible')
      , ('35274', 'Database Recovery Pending') , ('35275', 'Database in Suspect State') , ('35276', 'Database Out of Sync')
      , ('41091', 'Replica Going Offline') , ('41131', 'Failed to Bring AG Online') , ('41142', 'Replica Cannot Become Primary')
      , ('41406', 'AG Not Ready for Auto Failover') , ('41414', 'Secondary Not Connected')
	
.NOTES
    Author: Deepam Ghosh
    Version: 1.0
*/
SET NOCOUNT ON;

DECLARE @alertName SYSNAME
      , @thisErrorNumber VARCHAR(6)
      , @sqlCommand nVARCHAR(max) = ''
      , @operatorName SYSNAME = 'SQLMonitor';

DECLARE @errorNumbers TABLE (ErrorNumber VARCHAR(6), AlertName VARCHAR(50));

 INSERT Into @errorNumbers
 VALUES ('1480' , 'AG Role Change (failover)')
      , ('976'  , 'Database Not Accessible')
      , ('983'  , 'Database Role Resolving')
      , ('3402' , 'Database Restoring')
      , ('19406', 'AG Replica Changed States')
      , ('35206', 'Connection Timeout')
      , ('35250', 'Connection to Primary Inactive')
      , ('35264', 'Data Movement Suspended')
      , ('35273', 'Database Inaccessible')
      , ('35274', 'Database Recovery Pending')
      , ('35275', 'Database in Suspect State')
      , ('35276', 'Database Out of Sync')
      , ('41091', 'Replica Going Offline')
      , ('41131', 'Failed to Bring AG Online')
      , ('41142', 'Replica Cannot Become Primary')
      , ('41406', 'AG Not Ready for Auto Failover')
      , ('41414', 'Secondary Not Connected');

DECLARE cur_ForEachErrorNumber CURSOR Local fast_forward 
FOR SELECT * FROM @errorNumbers;

OPEN cur_ForEachErrorNumber;
FETCH NEXT FROM cur_ForEachErrorNumber INTO @thisErrorNumber, @alertName;

WHILE @@fetch_status = 0
BEGIN

IF NOT EXISTS(SELECT * FROM msdb.dbo.sysalerts s Where s.message_id = @thisErrorNumber)
BEGIN 

	EXECUTE msdb.dbo.sp_add_alert 
			@name = @alertName
		  , @message_id = @thisErrorNumber
		  , @severity = 0
		  , @enabled = 1 
		  , @delay_between_responses = 0 
		  , @include_event_description_in = 1 
		  , @job_id = N'00000000-0000-0000-0000-000000000000';

	EXECUTE msdb.dbo.sp_add_notification 
			@alert_name = @alertName
		  , @operator_name = @operatorName
		  , @notification_method = 1;

    RAISERROR('Alert ''%s'' for error number %s created.', 0,0, @alertName, @thisErrorNumber) WITH NOWAIT;
END

ELSE
BEGIN
	RAISERROR('Alert ''%s'' Already Exists.', 11,1, @alertName) WITH NOWAIT
END

FETCH NEXT FROM cur_ForEachErrorNumber Into @thisErrorNumber, @alertName;
END 

--==== Close/Deallocate cursor
CLOSE cur_ForEachErrorNumber;
DEALLOCATE cur_ForEachErrorNumber;