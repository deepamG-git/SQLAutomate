/*
.SYNOPSIS
    sp_RootBlocker Stored Procedure Creation Scripts
.DESCRIPTION
   Creates dbo.sp_RootBlocker stored procedure in DBAdmin database
   Used to find out Root SPID which is causing Database Blocking.
.NOTES
    Author: Deepam Ghosh
    Version: 1.0
 */

USE [DBAdmin]
GO

/****** Object:  StoredProcedure [dbo].[sp_RootBlocker]    Script Date: 8/23/2024 12:05:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



create procedure [dbo].[sp_RootBlocker] as

SELECT SPID, BLOCKED, REPLACE (REPLACE (T.TEXT, CHAR(10), ' '), CHAR (13), ' ' ) AS BATCH
 
INTO #T
 
FROM sys.sysprocesses R CROSS APPLY sys.dm_exec_sql_text(R.SQL_HANDLE) T
 

;WITH BLOCKERS (SPID, BLOCKED, LEVEL, BATCH)
 
AS
 
(
 
SELECT SPID,
 
BLOCKED,
 
CAST (REPLICATE ('0', 4-LEN (CAST (SPID AS VARCHAR))) + CAST (SPID AS VARCHAR) AS VARCHAR (1000)) AS LEVEL,
 
BATCH FROM #T R
 
WHERE (BLOCKED = 0 OR BLOCKED = SPID)
 
AND EXISTS (SELECT * FROM #T R2 WHERE R2.BLOCKED = R.SPID AND R2.BLOCKED <> R2.SPID)
 
UNION ALL
 
SELECT R.SPID,
 
R.BLOCKED,
 
CAST (BLOCKERS.LEVEL + RIGHT (CAST ((1000 + R.SPID) AS VARCHAR (100)), 4) AS VARCHAR (1000)) AS LEVEL,
 
R.BATCH FROM #T AS R
 
INNER JOIN BLOCKERS ON R.BLOCKED = BLOCKERS.SPID WHERE R.BLOCKED > 0 AND R.BLOCKED <> R.SPID
 
)
 
SELECT N'    ' + REPLICATE (N'|         ', LEN (LEVEL)/4 - 1) +
 
CASE WHEN (LEN(LEVEL)/4 - 1) = 0
 
THEN 'HEAD -  '
 
ELSE '|------  ' END
 
+ CAST (SPID AS NVARCHAR (10)) + N' ' + BATCH AS BLOCKING_TREE
 
FROM BLOCKERS ORDER BY LEVEL ASC
 

 
DROP TABLE #T
 
GO


