/*
.SYNOPSIS
    TruncateDBAdminData Job Creation Script
.DESCRIPTION
   Creates DBA_TruncateDBAdminData SQL Agent Job
   Deletes DBA related information from the DBAdmin tables which are older than 1 week.
   Frequency - Daily Once
.NOTES
    Author: Deepam Ghosh
    Version: 1.0
*/

USE [msdb]
GO

/****** Object:  Job [DBA_TruncateDBAdminData]    Script Date: 5/17/2024 4:08:52 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 5/17/2024 4:08:52 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA_TruncateDBAdminData', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Deletes rows from Inventory tables in DBAdmin Database where data is older than 1 week', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa',
		@notify_email_operator_name=N'DBAdmins',@job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Delete]    Script Date: 5/17/2024 4:08:52 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Delete', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [DBAdmin]

DELETE FROM [DBAdmin].[dbo].[tbl_ServerOSDetails] WHERE  DATEDIFF(DAY,[DataUpdatedOn], GETDATE()) > 7

DELETE FROM [DBAdmin].[dbo].[tbl_DiskDetails] WHERE  DATEDIFF(DAY,[DataUpdatedOn], GETDATE()) > 7

DELETE FROM [DBAdmin].[dbo].[tbl_SQLSvcAccounts] WHERE  DATEDIFF(DAY,[DataUpdatedOn], GETDATE()) > 7

DELETE FROM [DBAdmin].[dbo].[tbl_SQLVersion] WHERE  DATEDIFF(DAY,[DataUpdatedOn], GETDATE()) > 7
  
DELETE FROM [DBAdmin].[dbo].[tbl_SQLServerConfigs] WHERE  DATEDIFF(DAY,[DataUpdatedOn], GETDATE()) > 7

DELETE FROM [DBAdmin].[dbo].[tbl_DatabaseDetails] WHERE  DATEDIFF(DAY,[DataUpdatedOn], GETDATE()) > 7

DELETE FROM [DBAdmin].[dbo].[tbl_DatabaseBackupDetails] WHERE  DATEDIFF(DAY,[DataUpdatedOn], GETDATE()) > 7
 
DELETE FROM [DBAdmin].[dbo].[tbl_FailedSQLJobs] WHERE  DATEDIFF(DAY,[DataUpdatedOn], GETDATE()) > 7

DELETE FROM [DBAdmin].[dbo].[tbl_DatabaseFileSpace] WHERE DATEDIFF(DAY,[DataUpdatedOn], GETDATE()) > 7

DELETE FROM [DBAdmin].[dbo].[tbl_SysAdmins] WHERE DATEDIFF(DAY,[DataUpdatedOn], GETDATE()) > 7
 ', 
		@database_name=N'DBAdmin', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20240517, 
		@active_end_date=99991231, 
		@active_start_time=73000, 
		@active_end_time=235959, 
		@schedule_uid=N'500ba584-6b93-4355-add2-795e5655877d'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

