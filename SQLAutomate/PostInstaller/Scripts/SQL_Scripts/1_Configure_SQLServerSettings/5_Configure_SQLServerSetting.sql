/*
.SYNOPSIS
    SQL Server Settings Configuration Script
.DESCRIPTION
    1.Set Min and Max Memory Value for SQL Server
	2.Set MAXDOP Value for SQL Server
	3.Set Cost Threshold for Parallelism Value for SQL Server
.NOTES
    Author: Deepam Ghosh
    Version: 1.0
*/

DECLARE 
 @minMemory VARCHAR(20) = 2028  --Define MIN MEMORY HERE
,@maxMemory VARCHAR(20) = 20480 --Define MAX MEMORY HERE
,@costThreshold VARCHAR(20) = 5 --Define COST THRESHOLD HERE
,@MAXDOP VARCHAR(20) = 2;		--Define MAXDOP HERE


EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE WITH OVERRIDE

EXEC sys.sp_configure N'min server memory (MB)', @minMemory
RAISERROR('Minimum Memory Allocated to SQL = %sMB',0,0,@minMemory) WITH NOWAIT

EXEC sys.sp_configure N'max server memory (MB)', @maxMemory
RAISERROR('Maximum Memory Allocated to SQL = %sMB',0,0,@maxMemory) WITH NOWAIT

EXEC sys.sp_configure N'cost threshold for parallelism', @costThreshold
RAISERROR('Cost Threshold for Parallelism Set to = %s',0,0,@costThreshold) WITH NOWAIT

EXEC sys.sp_configure N'max degree of parallelism', @MAXDOP
RAISERROR('MAX DOP Set to = %s',0,0,@MAXDOP) WITH NOWAIT

EXEC sys.sp_configure N'show advanced options', N'0'  RECONFIGURE WITH OVERRIDE
