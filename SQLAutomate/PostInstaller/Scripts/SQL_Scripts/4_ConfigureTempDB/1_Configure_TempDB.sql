/*
.SYNOPSIS
    SQL Server TempDB Configuration Script
.DESCRIPTION
   Once TempDB is created during SQL Installation, this script can be used to perform below tasks-
   1.Modify TempDB Data and Log File Size
   2.Add a New TempDB Data Files(s)
.NOTES
    Author: Deepam Ghosh
    Version: 1.0
*/

DECLARE @tempdbCurrentDataFilecount INT = 4  --Existing Number of TempDB Data Files
DECLARE @tempdbNewDataFileCount INT = 0		 --Additonal Number of Data Files(.ndf) which needs to be added. Default - 0
DECLARE @tempdbNewDataFileLocation NVARCHAR(256) = 'E:\SQLAUTOMATE\TempDB\Log'  --Location where TempDB files will be stored
DECLARE @dataFileSizeMB NVARCHAR(50) = '2048MB'
DECLARE @logFileSizeMB NVARCHAR(50) = '2048MB'
DECLARE @fileGrowthMB NVARCHAR(50) = '2048MB'
DECLARE @i INT = 2
DECLARE @j NVARCHAR(16)

DECLARE @errorMessage NVARCHAR(MAX)
DECLARE @sql NVARCHAR(MAX)

--Setting Log File Size
SET @sql = 'USE [master]
			ALTER DATABASE ' + QUOTENAME('tempdb') + ' MODIFY FILE ( NAME = N''templog'', SIZE = ' + @logFileSizeMB + ', FILEGROWTH = ' + @fileGrowthMB + ')'
			
BEGIN TRY				
	EXEC(@sql)
	--print @sql
	RAISERROR('Size of TempDB log file-''templog'' set to %s. Restart the SQL Services to reflect the changes.',0,0,@logFileSizeMB)
END TRY
BEGIN CATCH
	SET @errorMessage = ERROR_MESSAGE() 
	RAISERROR('Error while setting size of TempDB Log File-''tempdev'' %s',11,1,@errorMessage)
END CATCH

--Setting Default Data File Size -tempdev
SET @sql = 'USE [master]
			ALTER DATABASE ' + QUOTENAME('tempdb') + ' MODIFY FILE ( NAME = N''tempdev'', SIZE = ' + @dataFileSizeMB + ', FILEGROWTH = ' + @fileGrowthMB + ')'

BEGIN TRY				
	EXEC(@sql)
	--print @sql
	RAISERROR('Size of TempDB data file-''tempdev'' set to %s. Restart the SQL Services to reflect the changes.',0,0,@dataFileSizeMB)
END TRY
BEGIN CATCH
	SET @errorMessage = ERROR_MESSAGE() 
	RAISERROR('Error while setting size of TempDB Data File-''tempdev'' %s',11,1,@errorMessage)
END CATCH


--Setting Additonal Data File Size
WHILE(@i <=@tempdbCurrentDataFilecount)
BEGIN
	SET @j = CONVERT(NVARCHAR(8),@i)
	SET @sql = 'USE [master]
				ALTER DATABASE ' + QUOTENAME('tempdb') + ' MODIFY FILE ( NAME = N''temp' + @j + ''', SIZE = ' + @dataFileSizeMB + ', FILEGROWTH = ' + @fileGrowthMB + ')'
BEGIN TRY
	EXEC(@sql)
	--print @sql
	RAISERROR('Size of TempDB Data file-''temp%s'' set to %s. Restart the SQL Services to reflect the changes.',0,0,@j,@dataFileSizeMB)
END TRY
BEGIN CATCH
	SET @errorMessage = ERROR_MESSAGE() 
	RAISERROR('Error while setting size of TempDB Data file-''temp%s'' %s',11,1,@j,@errorMessage)
END CATCH
SET @i = @i + 1
END


--Adding additonal Data Files to tempdb if @tempdbNewDataFileCount <>0
IF (@tempdbNewDataFileCount <> 0)
BEGIN
	WHILE (@tempdbNewDataFileCount > 0)
	BEGIN
	SET @j = CONVERT(NVARCHAR(8),@tempdbCurrentDataFilecount+1)
		SET @sql = 'USE [master]
				ALTER DATABASE ' + QUOTENAME('tempdb') + ' ADD FILE ( NAME = N''temp' + @j  + ''', FILENAME = N''' + @tempdbNewDataFileLocation +'\tempdb_mssql_' + @j + '.ndf' + ''', SIZE = ' + @dataFileSizeMB + ', FILEGROWTH = ' + @fileGrowthMB + ')'
				
		BEGIN TRY
			EXEC(@sql)
			--PRINT @sql
			RAISERROR('Added a new Data File in TempDB -''temp%s'' and size set to %s. Restart the SQL Services to reflect the changes.',0,0,@j,@dataFileSizeMB)
		END TRY
		BEGIN CATCH
			SET @errorMessage = ERROR_MESSAGE() 
			RAISERROR('Error while adding a new Data File in TempDB -''temp%s'' %s',11,1,@j,@errorMessage)
		END CATCH
		
	SET @tempdbCurrentDataFilecount = @tempdbCurrentDataFilecount + 1
	SET @tempdbNewDataFileCount = @tempdbNewDataFileCount - 1	
	END
END