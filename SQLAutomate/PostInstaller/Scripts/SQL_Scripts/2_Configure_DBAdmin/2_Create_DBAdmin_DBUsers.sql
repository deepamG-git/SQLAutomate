/*
.SYNOPSIS
    DBAdmin Database Default Database User and Loin Creation Script
.DESCRIPTION
   Creates a Login DataCollector
   Creates a Database User DataCollector
   Assignes db_owner database role to DataCollector
.NOTES
    Author: Deepam Ghosh
    Version: 1.0
*/


USE [master]
GO
CREATE LOGIN [DataCollector] WITH PASSWORD=N'DBAUser@1234', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
USE [DBAdmin]
GO
CREATE USER [DataCollector] FOR LOGIN [DataCollector]
GO
USE [DBAdmin]
GO
ALTER ROLE [db_owner] ADD MEMBER [DataCollector]
GO
