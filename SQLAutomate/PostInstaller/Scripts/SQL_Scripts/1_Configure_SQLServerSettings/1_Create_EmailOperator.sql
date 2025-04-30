/*
.SYNOPSIS
    SQL Server Database Email Operator Configuration Script
.DESCRIPTION
    1.Setup SQL Server Operators
.NOTES
    Author: Deepam Ghosh
    Version: 1.0
*/

USE [msdb]
GO


IF EXISTS(select * from msdb.dbo.sysoperators WHERE name = 'SQLMonitor')
BEGIN
	RAISERROR('Operator SQLMonitor Already Exits',11,1) WITH NOWAIT
END
ELSE
BEGIN
	/****** Object:  Operator [SQLMonitor]    Script Date: 10/14/2024 2:41:16 PM ******/
	EXEC msdb.dbo.sp_add_operator @name=N'SQLMonitor', 
			@enabled=1, 
			@weekday_pager_start_time=90000, 
			@weekday_pager_end_time=180000, 
			@saturday_pager_start_time=90000, 
			@saturday_pager_end_time=180000, 
			@sunday_pager_start_time=90000, 
			@sunday_pager_end_time=180000, 
			@pager_days=0, 
			@email_address=N'dbadmins@example.com', 
			@category_name=N'[Uncategorized]'

	RAISERROR('Operator SQLMonitor Created.',0,0) WITH NOWAIT
END




