/*
.SYNOPSIS
    DataCollector Job Creation Script
.DESCRIPTION
   Creates DBA_DataCollector SQL Agent Job
   Collects Server Level Info like OS Details, Disk Details, Service Account Details
   Collects SQL Level Info like SQL Version, SQL Config Details, DB Backups Details,SQL Job Details, etc.
   Frequency - Daily Once
.NOTES
    Author: Deepam Ghosh
    Version: 1.0
*/


USE [msdb]
GO

/****** Object:  Job [DBA_DataCollector]    Script Date: 8/22/2024 11:50:53 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 8/22/2024 11:50:53 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA_DataCollector', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Collects Below Information of SQL Server and Insert into DBAdmin Database tables-
1. OS Details
2. Disk Details
3. SQL Service Account Details
4. SQL Version
5. SQL Server Configurations
6. Database Details
7. Database Backup Details
8. Maintenance Job Details
9. Database File Space
10.Sysadmins Details', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBAdmins', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [OS_Details]    Script Date: 8/22/2024 11:50:53 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'OS_Details', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'$systemInfo = Get-ComputerInfo | Select-Object -Property CsDNSHostname,CsDomain,OsName,WindowsInstallDateFromRegistry,OsTotalVisibleMemorySize,CsNumberOfLogicalProcessors,CsProcessors,OsLastBootUpTime,Timezone

$machineName = $systemInfo.CsDNSHostName
$domain = $systemInfo.CsDomain
$OSName = $systemInfo.OsName
$cores = $systemInfo.CsNumberOfLogicalProcessors
$processor = $systemInfo.CsProcessors.Name
$ram = $systemInfo.OsTotalVisibleMemorySize
$OSInstallDate = $systemInfo.WindowsInstallDateFromRegistry
$OSLastBootTime = $systemInfo.OsLastBootUpTime
$timezone = $systemInfo.Timezone

$ramGB = -join([Math]::CEILING([Math]::Round($ram/1024/1024,2)), '' GB'')
<#Change the below two values accordinly    
$platform = "OnPrem"
$location = "India"
$description = "Backup-Testing Server"
#> 

$ipConfig = Get-NetIPConfiguration | Where-Object{$_.ipv4defaultgateway -ne $null}

try{
    $cluster = Get-Cluster | Select-Object -Property Name
    $clusterAGRole = Get-ClusterResource | Where-Object{$_.ResourceType -like ''SQL Server Availability Group''} | Select-Object -Property Name
    $clusterOwnerNode = Get-ClusterGroup | Where-Object{$_.Name -eq $clusterAGRole.Name} | Select-Object -Property OwnerNode
    echo "Error in try"
    $serverType = "Clustered"
    $clusterName = $cluster.Name
}
catch{
    $serverType = "Standalone"
    $clusterName = "N/A"
}



if($serverType -eq "Clustered"){
    if($machineName -eq $clusterOwnerNode.OwnerNode.Name){
        $ipAddress = $ipConfig.IPv4Address.ipaddress[0]
    }
    else{
        $ipAddress = $ipConfig.IPv4Address.ipaddress  
    }
} 
else{

    $ipAddress = $ipConfig.IPv4Address.ipaddress
}

$instance = "SQLInstance"
$database = "DBAdmin"



$query2 = "INSERT INTO [DBADMIN].[dbo].[tbl_ServerOSDetails]([ServerName],[IPAddress],[Domain],[ServerType],[ClusterName],[OperatingSystem],[RAM],[Cores],[Processor],[LastBootDate],[TimeZone]
             ,[OSInstallDate]) VALUES(''$machineName'',''$ipAddress'',''$domain'',''$serverType'',''$clusterName'',''$OSName'',''$ramGB'',''$cores'',''$processor'',''$OSLastBootTime'',''$timezone'',''$OSInstallDate'')"


Write-Output $query2


try{
    Invoke-Sqlcmd -ServerInstance $instance -Database $database -Query $query2  -QueryTimeout 60 -ErrorAction Stop
    Write-Host "OS Details Inserted on Table"
}
catch{
    Write-Host "Insertion Failed"
    
}
#$error


', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [DiskDetails]    Script Date: 8/22/2024 11:50:53 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DiskDetails', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'$diskDetails = Get-WmiObject -Class win32_logicaldisk | Where-Object {$_.DriveType -eq 3}  |
                Select-Object -Property DeviceID,VolumeName,@{Label=''TotalSpace(GB)'';Expression={($_.Size/1GB).ToString(''F2'')}}  ,@{Label=''FreeSpace(GB)'';Expression={($_.FreeSpace/1GB).ToString(''F2'')}} ,
                @{Label=''PercentFree'';Expression={((($_.FreeSpace/$_.Size))*100.00).ToString(''F2'')}}

#CHANGE THE BELOW INSTANCE NAME ACCORDINGLY

$instance = "SQLInstance"
$database = "DBAdmin"
$hostname = $env:COMPUTERNAME

foreach($disk in $diskDetails){
    $mountPoint = $disk.DeviceID
    $diskName = $disk.VolumeName
    $totalSpace = $disk.''TotalSpace(GB)''
    $freeSpace = $disk.''FreeSpace(GB)''
    $perctFree = $disk.PercentFree    

    $query2 = "INSERT INTO [DBAdmin].[DBO].[tbl_DiskDetails]([ServerName],[MountPoint],[DiskName],[TotalSpace(GB)],[FreeSpace(GB)],[PercentFree]) 
                    VALUES (''$hostname'',''$mountPoint'',''$diskName'',''$totalSpace'',''$freeSpace'',''$perctFree'')"
    #Write-Host $query2

   try{
       Invoke-Sqlcmd -ServerInstance $instance -Database $database -Query $query2 -QueryTimeout 60 -ErrorAction Stop
       Write-Host "Inserted Disk Details information into the database." 
   }
   catch{
       Write-Host "Failed to insert Disk Details information into the database:"
   }
   
 }

', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [SvcAccount_Details]    Script Date: 8/22/2024 11:50:53 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'SvcAccount_Details', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'$services = Get-WmiObject Win32_Service | Where-Object {$_.DisplayName -like ''SQL Server*'' } | Select-Object DisplayName, StartName

$instance = "SQLInstance"
$database = "DBAdmin"
$hostname = $env:COMPUTERNAME

foreach ($service in $services) {
    $svcName = $service.DisplayName
    $svcAccount = $service.StartName

    $query2 = "INSERT INTO [DBAdmin].[dbo].[tbl_SQLSvcAccounts] ([ServerName], [ServiceName], [ServiceAccount]) VALUES (''$hostname'', ''$svcName'', ''$svcAccount'')"
    
    try {
        Invoke-Sqlcmd -ServerInstance $instance -Database $database -Query $query2 -QueryTimeout 60 -ErrorAction Stop
        Write-Host "Inserted service information into the database."
    } catch {
        Write-Host "Failed to insert service information into the database:"
        # Log error here
    }
}
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [SQLVersion_Details]    Script Date: 8/22/2024 11:50:53 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'SQLVersion_Details', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
--DELETE FROM [DBAdmin].[dbo].[tbl_SQLVersion] WHERE [InstanceName] = (CONVERT(NVARCHAR,SERVERPROPERTY(''ServerName'')))

INSERT INTO [DBAdmin].[dbo].[tbl_SQLVersion]([ServerName],[InstanceName] ,[InstanceType],[Product],[ProductVersion] ,[ProductLevel])
 SELECT  
	CONVERT(NVARCHAR,SERVERPROPERTY(''MachineName''))
	,CONVERT(NVARCHAR,SERVERPROPERTY(''ServerName''))
	,CASE
		WHEN SERVERPROPERTY(''InstanceName'') IS NULL THEN ''Default Instance''
		ELSE ''Named Instance''
	END AS ''Instance Type''
	,CASE	
		WHEN (SERVERPROPERTY(''ProductMajorVersion'')  = ''16'' AND SERVERPROPERTY(''ProductMinorVersion'') = ''0'') THEN CONCAT(''Microsoft SQL Server 2022 '',CONVERT(NVARCHAR,SERVERPROPERTY(''Edition'')))
		WHEN (SERVERPROPERTY(''ProductMajorVersion'')  = ''15'' AND SERVERPROPERTY(''ProductMinorVersion'') = ''0'') THEN CONCAT(''Microsoft SQL Server 2019 '',CONVERT(NVARCHAR,SERVERPROPERTY(''Edition'')))
		WHEN (SERVERPROPERTY(''ProductMajorVersion'')  = ''14'' AND SERVERPROPERTY(''ProductMinorVersion'') = ''0'') THEN CONCAT(''Microsoft SQL Server 2017 '',CONVERT(NVARCHAR,SERVERPROPERTY(''Edition'')))
		WHEN (SERVERPROPERTY(''ProductMajorVersion'')  = ''13'' AND SERVERPROPERTY(''ProductMinorVersion'') = ''0'') THEN CONCAT(''Microsoft SQL Server 2016 '',CONVERT(NVARCHAR,SERVERPROPERTY(''Edition'')))
		WHEN (SERVERPROPERTY(''ProductMajorVersion'')  = ''12'' AND SERVERPROPERTY(''ProductMinorVersion'') = ''0'') THEN CONCAT(''Microsoft SQL Server 2014 '',CONVERT(NVARCHAR,SERVERPROPERTY(''Edition'')))
		WHEN (SERVERPROPERTY(''ProductMajorVersion'')  = ''11'' AND SERVERPROPERTY(''ProductMinorVersion'') = ''0'') THEN CONCAT(''Microsoft SQL Server 2012 '',CONVERT(NVARCHAR,SERVERPROPERTY(''Edition'')))
		WHEN (SERVERPROPERTY(''ProductMajorVersion'')  = ''10'' AND SERVERPROPERTY(''ProductMinorVersion'') = ''50'') THEN CONCAT(''Microsoft SQL Server 2008 R2 '',CONVERT(NVARCHAR,SERVERPROPERTY(''Edition'')))
		WHEN (SERVERPROPERTY(''ProductMajorVersion'')  = ''10'' AND SERVERPROPERTY(''ProductMinorVersion'') = ''0'') THEN CONCAT(''Microsoft SQL Server 2008 '',CONVERT(NVARCHAR,SERVERPROPERTY(''Edition'')))
		ELSE ''SQL Not Found''
	END AS ''Product Version''
	,CONVERT(NVARCHAR,SERVERPROPERTY(''ProductVersion'')) 
	,CONVERT(NVARCHAR,SERVERPROPERTY(''ProductLevel''))', 
		@database_name=N'DBAdmin', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [SQLServerConfig_Details]    Script Date: 8/22/2024 11:50:53 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'SQLServerConfig_Details', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
--DELETE FROM  [DBAdmin].[dbo].[tbl_SQLServerConfigs] WHERE [InstanceName] = (CONVERT(NVARCHAR,SERVERPROPERTY(''ServerName'')))


DECLARE @server NVARCHAR(100) = (CONVERT(NVARCHAR,SERVERPROPERTY(''MachineName'')))
DECLARE @instance NVARCHAR(100) = (CONVERT(NVARCHAR,SERVERPROPERTY(''ServerName'')))
DECLARE @sqlVersion NVARCHAR(100) = (SELECT CASE	
									WHEN (SERVERPROPERTY(''ProductMajorVersion'')  = ''16'' AND SERVERPROPERTY(''ProductMinorVersion'') = ''0'') THEN CONCAT(''Microsoft SQL Server 2022 '',CONVERT(NVARCHAR,SERVERPROPERTY(''Edition'')))
									WHEN (SERVERPROPERTY(''ProductMajorVersion'')  = ''15'' AND SERVERPROPERTY(''ProductMinorVersion'') = ''0'') THEN CONCAT(''Microsoft SQL Server 2019 '',CONVERT(NVARCHAR,SERVERPROPERTY(''Edition'')))
									WHEN (SERVERPROPERTY(''ProductMajorVersion'')  = ''14'' AND SERVERPROPERTY(''ProductMinorVersion'') = ''0'') THEN CONCAT(''Microsoft SQL Server 2017 '',CONVERT(NVARCHAR,SERVERPROPERTY(''Edition'')))
									WHEN (SERVERPROPERTY(''ProductMajorVersion'')  = ''13'' AND SERVERPROPERTY(''ProductMinorVersion'') = ''0'') THEN CONCAT(''Microsoft SQL Server 2016 '',CONVERT(NVARCHAR,SERVERPROPERTY(''Edition'')))
									WHEN (SERVERPROPERTY(''ProductMajorVersion'')  = ''12'' AND SERVERPROPERTY(''ProductMinorVersion'') = ''0'') THEN CONCAT(''Microsoft SQL Server 2014 '',CONVERT(NVARCHAR,SERVERPROPERTY(''Edition'')))
									WHEN (SERVERPROPERTY(''ProductMajorVersion'')  = ''11'' AND SERVERPROPERTY(''ProductMinorVersion'') = ''0'') THEN CONCAT(''Microsoft SQL Server 2012 '',CONVERT(NVARCHAR,SERVERPROPERTY(''Edition'')))
									WHEN (SERVERPROPERTY(''ProductMajorVersion'')  = ''10'' AND SERVERPROPERTY(''ProductMinorVersion'') = ''50'') THEN CONCAT(''Microsoft SQL Server 2008 R2 '',CONVERT(NVARCHAR,SERVERPROPERTY(''Edition'')))
									WHEN (SERVERPROPERTY(''ProductMajorVersion'')  = ''10'' AND SERVERPROPERTY(''ProductMinorVersion'') = ''0'') THEN CONCAT(''Microsoft SQL Server 2008 '',CONVERT(NVARCHAR,SERVERPROPERTY(''Edition'')))
									ELSE ''SQL Not Found''
									END AS ''Product Version'')

DECLARE @minMemoryMB NVARCHAR(50) = (CONVERT(NVARCHAR,(SELECT VALUE FROM sys.configurations WHERE NAME = ''min server memory (MB)'')))
DECLARE @maxMemoryMB NVARCHAR(50) = (CONVERT(NVARCHAR,(SELECT VALUE FROM sys.configurations WHERE NAME = ''max server memory (MB)'')))
DECLARE @dbMail NVARCHAR(50) = (SELECT CASE WHEN VALUE = 1 THEN ''Enabled'' ELSE ''Disabled'' END AS ''DB MAIL Feature'' FROM sys.configurations WHERE NAME = ''Database Mail XPs'')
DECLARE @xpCMD NVARCHAR(50) = (SELECT CASE WHEN VALUE = 1 THEN ''Enabled'' ELSE ''Disabled'' END AS ''xpcmdShell'' FROM sys.configurations WHERE NAME = ''xp_cmdshell'')
DECLARE @ctparallel INT = (CONVERT(INT,(SELECT VALUE FROM sys.configurations WHERE NAME = ''cost threshold for parallelism'')))
DECLARE @maxdop INT = (CONVERT(INT,(SELECT VALUE FROM sys.configurations WHERE NAME = ''max degree of parallelism'')))
DECLARE @adhocWork NVARCHAR(50) = (SELECT  CASE WHEN VALUE = 1 THEN ''Enabled'' ELSE ''Disabled'' END AS''Adhoc Workload'' FROM sys.configurations WHERE NAME = ''optimize for ad hoc workloads'')
DECLARE @lockPage NVARCHAR(50) = (SELECT CASE  WHEN sql_memory_model <>  2 THEN ''Disabled'' ELSE ''Enabled'' END AS ''LockPagesInMemory'' FROM sys.dm_os_sys_info )
DECLARE @ifi NVARCHAR(50) = (SELECT CASE WHEN instant_file_initialization_enabled = ''Y'' THEN ''Enabled'' ELSE ''Disabled'' END AS ''IFI'' FROM sys.dm_server_services where servicename like ''SQL Server (%'')

DECLARE @masterDataFilePath NVARCHAR(255) = (SELECT [filename] FROM SYS.sysaltfiles WHERE NAME = ''master'')
DECLARE @masterLogFilePath NVARCHAR(255) = (SELECT [filename] FROM SYS.sysaltfiles WHERE NAME = ''mastlog'')
DECLARE @defaultBkpPath NVARCHAR(255) = (CONVERT(NVARCHAR,( SERVERPROPERTY(''InstanceDefaultBackupPath''))))
DECLARE @defaultDataPath NVARCHAR(255) = (CONVERT(NVARCHAR,( SERVERPROPERTY(''InstanceDefaultDataPath''))))
DECLARE @defaultLogPath NVARCHAR(255) = (CONVERT(NVARCHAR,( SERVERPROPERTY(''InstanceDefaultLogPath''))))

DECLARE @serverCollation NVARCHAR(50) = (CONVERT(NVARCHAR,(SELECT SERVERPROPERTY(''COLLATION''))))
DECLARE @tempDBMemoryOptm NVARCHAR(10) =  (SELECT CASE WHEN SERVERPROPERTY(''IsTempDbMetadataMemoryOptimized'') = 1 THEN ''Yes'' ELSE ''No'' END AS ''TempDB Enabled for Memory Optimized Tables'' )
DECLARE @inMemoryOLTPSupport NVARCHAR(10) =  (SELECT CASE WHEN SERVERPROPERTY(''IsXTPSupported'') = 1 THEN ''Yes'' ELSE ''Yes'' END AS ''IN Memory OLTP Supported'' )
DECLARE @fileStream NVARCHAR(10) =  (SELECT CASE WHEN SERVERPROPERTY(''FilestreamConfiguredLevel'') = 1 THEN ''Enabled'' ELSE ''Disabled'' END AS ''FilestreamConfiguredLevel'' )
DECLARE @HADR NVARCHAR(50) = (SELECT CASE WHEN SERVERPROPERTY(''IsHadrEnabled'') = 1 THEN ''AlwaysOn AG Enabled'' ELSE ''AlwaysOn AG Disabled'' END AS ''HADR'')
DECLARE @authType NVARCHAR(50) = (SELECT CASE WHEN SERVERPROPERTY(''IsIntegratedSecurityOnly'') = 1 THEN ''Integrated security (Windows Authentication)'' ELSE ''Both(Windows and SQL Server Authentication)'' END AS ''Authentication Type'')


INSERT INTO [DBAdmin].[dbo].[tbl_SQLServerConfigs]([ServerName],[InstanceName],[SQLVersion],[Collation],[MinMemory(MB)],[MaxMemory(MB)],[MaxDOP],[CostThresholdParallelism],[AdhocWorkLoad],[LockPageinMemory],
[InstantFileInitialization],[DBMailFeature] ,[XP_CMDShell],[HADRStatus] ,[ServerAuthentication],[TempDBOptimizedForInMemoryTables] ,[InMemoryOLTPSupported] ,[FileStream] ,
[MasterDataFilePath],[MasterDataLogPath],[DefaultDataPath] ,[DefaultLogPath] ,[DefaultBackupPath]) 
VALUES (@server,@instance,@sqlVersion,@serverCollation,@minMemoryMB,@maxMemoryMB,@maxdop,@ctparallel,@adhocWork,@lockPage,@ifi,@dbMail,@xpCMD,@HADR,@authType,@tempDBMemoryOptm,@inMemoryOLTPSupport,@fileStream,
@masterDataFilePath,@masterLogFilePath,@defaultDataPath,@defaultLogPath,@defaultBkpPath)
', 
		@database_name=N'DBAdmin', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [DBDetails]    Script Date: 8/22/2024 11:50:53 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DBDetails', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
--DELETE FROM  [DBAdmin].[dbo].[tbl_SQLServerConfigs] WHERE [InstanceName] = (CONVERT(NVARCHAR,SERVERPROPERTY(''ServerName'')))

--Calculating Overall Database Size Separately
IF OBJECT_ID(''tempdb..#dbsize'') is not null
DROP TABLE #dbsize

CREATE TABLE #dbsize(
[DatabaseName] NVARCHAR(50)
,[DatabaseSize] NVARCHAR(50)
)

DECLARE @db NVARCHAR(50)
DECLARE @sql NVARCHAR(max)

DECLARE dbsize CURSOR
FOR SELECT NAME FROM sys.databases WHERE NAME NOT IN (''master'',''model'',''msdb'',''tempdb'') and state_desc <> ''offline''

OPEN dbsize
FETCH NEXT FROM dbsize INTO @db

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @sql = ''USE '' + @db + '' 
	SELECT 
		DB_NAME(),
		CASE 
			WHEN SUM(A.TotalSizeMB) < 1000 THEN CONCAT(SUM(A.TotalSizeMB),'''' MB'''') 
			WHEN (SUM(A.TotalSizeMB) >=1000 AND SUM(A.TotalSizeMB) <1000000) THEN CONCAT(CONVERT(DECIMAL(10,2),SUM(A.TotalSizeMB)/1024.0),'''' GB'''')
			WHEN SUM(A.TotalSizeMB) >= 1000000 THEN  CONCAT(CONVERT(DECIMAL(10,2),SUM(A.TotalSizeMB)/1024.0/1024.0),'''' TB'''') 
			END AS [DatabaseSize]
			FROM
		(SELECT DB_NAME() AS DbName,
		CONVERT(DECIMAL(10,2),size/128.0) AS TotalSizeMB
		FROM sys.database_files
		) AS A 
		GROUP BY A.DBNAME''
		--PRINT @sql
		INSERT INTO #dbsize EXEC sp_executesql @sql
		FETCH NEXT FROM dbsize INTO @db
END
CLOSE dbsize
DEALLOCATE dbsize

--Fetching Database Properties


INSERT INTO [DBAdmin].[DBO].[tbl_DatabaseDetails]([InstanceName] ,[DatabaseName] ,[Owner] ,[Size] ,[CreatedOn],[State] ,[Type] ,[RecoveryModel] ,[Collation] ,[CompatabilityLevel] ,[UserAccessType] 
			,[Encryption] ,[QueryStore] ,[CDC] ,[AutoUpdateStats] )
			SELECT CONVERT(NVARCHAR(100),SERVERPROPERTY(''ServerName'')) AS [InstanceName]
			,a.name as [DatabaseName]
			,b.name as [Owner]
			,c.DatabaseSize as [Size] 
			,a.create_date as [CreateOn]
			,a.state_desc as [State]
			,CASE WHEN a.is_read_only = 0 THEN ''READ_WRITE'' ELSE ''READ_ONLY'' END AS [Type]
			,a.recovery_model_desc as [RecoveryModel]
			,a.collation_name as [Collation]
			,a.compatibility_level as [CompatibilityLevel]
			,a.user_access_desc as [UserAccessType]
			,CASE WHEN a.is_encrypted = 0 THEN ''Disabled'' ELSE ''Enabled'' END AS [Encryption]
			,CASE WHEN a.is_query_store_on = 0 THEN ''Disabled'' ELSE ''Enabled'' END AS [QueryStore]
			,CASE WHEN a.is_cdc_enabled = 0 THEN ''Disabled'' ELSE ''Enabled'' END AS [CDC]
			,CASE WHEN a.is_auto_update_stats_on = 0 THEN ''Disabled'' ELSE ''Enabled'' END AS [AutoUpdateStats]
			from sys.databases a,
			sys.server_principals b,
			tempdb..#dbsize c
			where a.owner_sid = b.sid and a.name = c.DatabaseName

DROP TABLE #dbsize', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [DBBackupDetails]    Script Date: 8/22/2024 11:50:53 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DBBackupDetails', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
/* For the databases whose backup happened and record exists in msdb*/
if OBJECT_ID(''tempdb..#db_list'') is not null
drop table #db_list
select name into #db_list from  sys.databases where name not in(''tempdb'')

--select * from #db_list

declare @fullbkpdate datetime
declare @diffbkpdate datetime
declare @db nvarchar(50)

while exists (select * from #db_list)
begin	
	set @db = (select top 1 name from #db_list order by name asc)
	set @fullbkpdate = (select top 1 backup_finish_date from msdb.dbo.backupset where database_name = @db and type = ''D''
							--and user_name = N''NT AUTHORITY\SYSTEM''
							order by backup_finish_date desc )
	set @diffbkpdate = (select top 1 backup_finish_date from msdb.dbo.backupset where database_name = @db and type = ''I''
							--and user_name = N''NT AUTHORITY\SYSTEM''
							order by backup_finish_date desc )
	insert into [DBAdmin].[dbo].[tbl_DatabaseBackupDetails]([InstanceName],[DatabaseName],[RecentFullBackupDate] ,[RecentDiffBackupDate]) 
				values(CONVERT(NVARCHAR(100),SERVERPROPERTY(''ServerName'')), @db, @fullbkpdate, @diffbkpdate)

	delete from #db_list where name = @db
end

drop table #db_list

--select * from [DBAdmin].[dbo].[tbl_DatabaseBackupDetails]', 
		@database_name=N'DBAdmin', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [MaintenanceJobDetails]    Script Date: 8/22/2024 11:50:53 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'MaintenanceJobDetails', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'



INSERT INTO [DBAdmin].[dbo].[tbl_FailedSQLJobs]([InstanceName],[JobName],[StepID] ,[StepName] ,[Status] ,[ExecutionTime] ,[ErrorMessage] )
SELECT DISTINCT 
	@@SERVERNAME
	,z.jobname
	,z.step_id
	,z.StepName
	,z.status
	,
	CONCAT( STUFF(STUFF(z.rundate,7,0,''-''),5,0,''-'')
	,'' ''
	, STUFF(STUFF(Z.runtime,5,0,'':''),3,0,'':'')
	)
	 AS [ExecutionTime]
	,z.[message]
	
FROM
	(SELECT  a.name as [jobname] ,b.step_id, b.step_name as [StepName],
						 CASE
								WHEN b.run_status = 0 THEN ''Failed''
								WHEN b.run_status = 1 THEN ''Succeeded''
								WHEN b.run_status = 3 THEN ''Cancelled''
								ELSE NULL
						 END AS [status]
						 ,CONVERT(NVARCHAR(50),b.run_date) [rundate]
						 ,case
							WHEN LEN(CONVERT(nvarchar(50),b.run_time)) = 6 THEN CONVERT(NVARCHAR(50),b.run_time)
							WHEN LEN(CONVERT(nvarchar(50),b.run_time)) = 5 THEN CONCAT(''0'',CONVERT(NVARCHAR(50),b.run_time)) 
							ELSE ''000000''
							END AS [runtime]
						,b.message
						,b.run_status
						FROM [msdb].[dbo].[sysjobs] a, msdb.dbo.sysjobhistory b
						WHERE a.job_id = b.job_id 
						and a.category_id = 3 
						and a.enabled = 1 
						and b.run_status in (0,3)  --Failed/Cancelled Steps 
						and b.step_id <> 0  --Step which failed/cancelled are included
						and b.run_date = (SELECT REPLACE((SELECT CONVERT(DATE, GETDATE())),''-'',''''))
	) Z

UNION

SELECT DISTINCT 
	@@SERVERNAME
	,z.jobname
	,z.step_id
	,z.StepName
	,z.status
	,
	CONCAT( STUFF(STUFF(z.rundate,7,0,''-''),5,0,''-'')
	,'' ''
	, STUFF(STUFF(Z.runtime,5,0,'':''),3,0,'':'')
	)
	 AS [ExecutionTime]
	,z.[message]
	
FROM
	(SELECT  a.name as [jobname] , b.step_id, b.step_name as [StepName],
						 CASE
								WHEN b.run_status = 0 THEN ''Failed''
								WHEN b.run_status = 1 THEN ''Succeeded''
								WHEN b.run_status = 3 THEN ''Cancelled''
								ELSE NULL
						 END AS [status]
						 ,CONVERT(NVARCHAR(50),b.run_date) [rundate]
						 ,case
							WHEN LEN(CONVERT(nvarchar(50),b.run_time)) = 6 THEN CONVERT(NVARCHAR(50),b.run_time)
							WHEN LEN(CONVERT(nvarchar(50),b.run_time)) = 5 THEN CONCAT(''0'',CONVERT(NVARCHAR(50),b.run_time)) 
							ELSE ''000000''
							END AS [runtime]
						,b.message
						,b.run_status
						FROM [msdb].[dbo].[sysjobs] a, msdb.dbo.sysjobhistory b
						WHERE a.job_id = b.job_id 
						and a.category_id = 3 
						and a.enabled = 1 
						and b.run_status = 1 --Completed Successfully
						and b.step_id = 0   --Fetchning only Job Outcome step
						and b.run_date = (SELECT REPLACE((SELECT CONVERT(DATE, GETDATE())),''-'',''''))
	) Z





', 
		@database_name=N'DBAdmin', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [DatabaseFileSpace]    Script Date: 8/22/2024 11:50:53 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DatabaseFileSpace', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
declare @db nvarchar(50)
declare @sql nvarchar(max)

declare dbsize cursor
for select name from sys.databases where name not in(''master'',''model'',''msdb'',''tempdb'') and state = 0

open dbsize
fetch next from dbsize into @db

while @@FETCH_STATUS = 0
begin
	set @sql = ''use '' + @db + '' 
	SELECT CONVERT(nvarchar,SERVERPROPERTY(''''servername'''')), DB_NAME() AS DbName, name AS FileName,type_desc AS FileType,
		cast(size/128.0 as decimal(10,2)) AS TotalSizeMB,
		cast((size/128.0 - CAST(FILEPROPERTY(name, ''''SpaceUsed'''') AS INT)/128.0) as decimal(10,2)) AS FreeSpaceMB,
		cast((cast((size/128.0 - CAST(FILEPROPERTY(name, ''''SpaceUsed'''') AS INT)/128.0) as decimal(10,2))/ cast(size/128.0 as decimal(10,2))) *100 as decimal(10,2))
		as PercentFreeSpace,
		cast(growth/128.0 as decimal(10,1)) as AutoGrowthMB,
		case
			when max_size = -1 then ''''Unlimited''''
			else cast(cast(max_size/128.0 as decimal(10,2)) as varchar)
			end as [MaximumSizeMB]
		FROM sys.database_files''
		print @sql
		insert into [DBAdmin].[dbo].[tbl_DatabaseFileSpace]([InstanceName],[DatabaseName],[FileName],[FileType],[TotalSizeMB],[FreeSpaceMB],[PercentFreeSpace],[AutoGrowthMB],
					[MaxSizeMB]) exec sp_executesql @sql
		fetch next from dbsize into @db
end
close dbsize
deallocate dbsize


', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Sysadmins Details]    Script Date: 8/22/2024 11:50:53 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Sysadmins Details', 
		@step_id=10, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'use master;

insert into DBAdmin.dbo.tbl_SysAdmins(InstanceName,LoginName,LoginType,AccessLevel,AccessGrantedOn)
select convert(nvarchar(50), SERVERPROPERTY(''servername'')),
a.name as [LoginName],b.type_desc as [LoginType], ''SysAdmin'' as [AccessLevel],a.updatedate as [AccessGrantedOn]
from sys.syslogins a,sys.server_principals b where 
a.sid = b.sid
and a.sysadmin = 1 
and a.hasaccess = 1 
order by AccessGrantedOn desc
', 
		@database_name=N'master', 
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
		@active_start_date=20240507, 
		@active_end_date=99991231, 
		@active_start_time=70000, 
		@active_end_time=235959, 
		@schedule_uid=N'db1583f2-adf7-4602-b38d-b308f8cb3d03'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

