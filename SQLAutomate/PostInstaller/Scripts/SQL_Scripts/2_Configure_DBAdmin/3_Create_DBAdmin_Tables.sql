/*
.SYNOPSIS
    DBAdmin Tables Creation Script
.DESCRIPTION
   Creates Below tables in DBAdmin database to store DBA Related and other important logging information
   [dbo].[CommandLog]
   [dbo].[IndexFragmentationList_New] 
   [dbo].[Table_Records] 
   [dbo].[Table_Records_ChangeRate]
   [dbo].[tbl_DatabaseBackupDetails] 
   [dbo].[tbl_DatabaseDetails]  
   [dbo].[tbl_DatabaseFileSpace]
   [dbo].[tbl_DiskDetails]
   [dbo].[tbl_FailedSQLJobs]
   [dbo].[tbl_ServerOSDetails] 
   [dbo].[tbl_SQLServerConfigs]
   [dbo].[tbl_SQLSvcAccounts]
   [dbo].[tbl_SQLVersion]
   [dbo].[tbl_SysAdmins] 
.NOTES
    Author: Deepam Ghosh
    Version: 1.0
*/

USE [DBAdmin]
GO

/****** Object:  Table [dbo].[CommandLog]    Script Date: 12/16/2024 1:48:39 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CommandLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DatabaseName] [sysname] NULL,
	[SchemaName] [sysname] NULL,
	[ObjectName] [sysname] NULL,
	[ObjectType] [char](2) NULL,
	[IndexName] [sysname] NULL,
	[IndexType] [tinyint] NULL,
	[StatisticsName] [sysname] NULL,
	[PartitionNumber] [int] NULL,
	[ExtendedInfo] [xml] NULL,
	[Command] [nvarchar](max) NOT NULL,
	[CommandType] [nvarchar](60) NOT NULL,
	[StartTime] [datetime2](7) NOT NULL,
	[EndTime] [datetime2](7) NULL,
	[ErrorNumber] [int] NULL,
	[ErrorMessage] [nvarchar](max) NULL,
 CONSTRAINT [PK_CommandLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[IndexFragmentationList_New]    Script Date: 12/16/2024 1:48:39 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[IndexFragmentationList_New](
	[DataCollected] [datetime] NOT NULL,
	[DatabaseName] [sysname] NOT NULL,
	[SchemaName] [sysname] NOT NULL,
	[ObjectName] [sysname] NOT NULL,
	[IndexName] [sysname] NOT NULL,
	[ObjectType] [sysname] NOT NULL,
	[IndexType] [sysname] NOT NULL,
	[PartitionNumber] [int] NULL,
	[PageCount] [int] NULL,
	[AvgFragmentationInPercent] [decimal](5, 2) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Table_Records]    Script Date: 12/16/2024 1:48:39 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Table_Records](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DatabaseName] [sysname] NOT NULL,
	[SchemaName] [sysname] NOT NULL,
	[TableName] [sysname] NOT NULL,
	[RecordsCount] [int] NULL,
	[DataCollected] [datetime] NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Table_Records_ChangeRate]    Script Date: 12/16/2024 1:48:39 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Table_Records_ChangeRate](
	[DatabaseName] [sysname] NOT NULL,
	[SchemaName] [sysname] NOT NULL,
	[TableName] [nvarchar](100) NULL,
	[Latest_Rowcount] [int] NULL,
	[Latest_Rowcount_Date] [date] NULL,
	[Secondlatest_Rowcount] [int] NULL,
	[Secondlatest_Rowcount_date] [date] NULL,
	[Changein_Rowcount] [int] NULL,
	[Change_Rate] [decimal](15, 4) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[tbl_DatabaseBackupDetails]    Script Date: 12/16/2024 1:48:39 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tbl_DatabaseBackupDetails](
	[InstanceName] [nvarchar](50) NOT NULL,
	[DatabaseName] [nvarchar](50) NOT NULL,
	[RecentFullBackupDate] [datetime] NULL,
	[RecentDiffBackupDate] [datetime] NULL,
	[DataUpdatedOn] [datetime] NOT NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[tbl_DatabaseDetails]    Script Date: 12/16/2024 1:48:39 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tbl_DatabaseDetails](
	[InstanceName] [nvarchar](100) NOT NULL,
	[DatabaseName] [nvarchar](50) NOT NULL,
	[Owner] [nvarchar](50) NOT NULL,
	[Size] [nvarchar](50) NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[State] [nvarchar](50) NOT NULL,
	[Type] [nvarchar](50) NOT NULL,
	[RecoveryModel] [nvarchar](50) NOT NULL,
	[Collation] [nvarchar](50) NOT NULL,
	[CompatabilityLevel] [int] NULL,
	[UserAccessType] [nvarchar](50) NOT NULL,
	[Encryption] [nvarchar](50) NOT NULL,
	[QueryStore] [nvarchar](50) NOT NULL,
	[CDC] [nvarchar](50) NOT NULL,
	[AutoUpdateStats] [nvarchar](50) NOT NULL,
	[DataUpdatedOn] [datetime] NOT NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[tbl_DatabaseFileSpace]    Script Date: 12/16/2024 1:48:39 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tbl_DatabaseFileSpace](
	[InstanceName] [nvarchar](50) NULL,
	[DatabaseName] [nvarchar](50) NULL,
	[FileName] [nvarchar](50) NULL,
	[FileType] [nvarchar](20) NULL,
	[TotalSizeMB] [decimal](10, 2) NULL,
	[FreeSpaceMB] [decimal](10, 2) NULL,
	[PercentFreeSpace] [decimal](10, 2) NULL,
	[AutoGrowthMB] [decimal](10, 2) NULL,
	[MaxSizeMB] [nvarchar](50) NULL,
	[DataUpdatedOn] [datetime] NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[tbl_DiskDetails]    Script Date: 12/16/2024 1:48:39 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tbl_DiskDetails](
	[ServerName] [nvarchar](100) NOT NULL,
	[MountPoint] [nvarchar](10) NOT NULL,
	[DiskName] [nvarchar](50) NULL,
	[TotalSpace(GB)] [nvarchar](50) NOT NULL,
	[FreeSpace(GB)] [nvarchar](50) NOT NULL,
	[PercentFree] [nvarchar](50) NOT NULL,
	[DataUpdatedOn] [datetime] NOT NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[tbl_FailedSQLJobs]    Script Date: 12/16/2024 1:48:39 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tbl_FailedSQLJobs](
	[InstanceName] [nvarchar](50) NOT NULL,
	[JobName] [nvarchar](50) NOT NULL,
	[StepID] [int] NOT NULL,
	[StepName] [nvarchar](100) NULL,
	[Status] [nvarchar](50) NOT NULL,
	[ExecutionTime] [datetime] NULL,
	[ErrorMessage] [nvarchar](max) NOT NULL,
	[DataUpdatedOn] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[tbl_ServerOSDetails]    Script Date: 12/16/2024 1:48:39 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tbl_ServerOSDetails](
	[ServerName] [nvarchar](100) NOT NULL,
	[IPAddress] [nvarchar](50) NOT NULL,
	[Domain] [nvarchar](100) NOT NULL,
	[ServerType] [nvarchar](100) NOT NULL,
	[ClusterName] [nvarchar](100) NOT NULL,
	[OperatingSystem] [nvarchar](255) NOT NULL,
	[RAM] [nvarchar](50) NOT NULL,
	[Cores] [nvarchar](50) NOT NULL,
	[Processor] [nvarchar](255) NOT NULL,
	[LastBootDate] [datetime] NOT NULL,
	[TimeZone] [nvarchar](255) NOT NULL,
	[OSInstallDate] [datetime] NOT NULL,
	[DataUpdatedOn] [datetime] NOT NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[tbl_SQLServerConfigs]    Script Date: 12/16/2024 1:48:39 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tbl_SQLServerConfigs](
	[ServerName] [nvarchar](100) NOT NULL,
	[InstanceName] [nvarchar](100) NOT NULL,
	[SQLVersion] [nvarchar](100) NOT NULL,
	[Collation] [nvarchar](50) NOT NULL,
	[MinMemory(MB)] [nvarchar](50) NOT NULL,
	[MaxMemory(MB)] [nvarchar](50) NOT NULL,
	[MaxDOP] [int] NOT NULL,
	[CostThresholdParallelism] [int] NOT NULL,
	[AdhocWorkLoad] [nvarchar](50) NOT NULL,
	[LockPageinMemory] [nvarchar](50) NOT NULL,
	[InstantFileInitialization] [nvarchar](50) NOT NULL,
	[DBMailFeature] [nvarchar](50) NOT NULL,
	[XP_CMDShell] [nvarchar](50) NOT NULL,
	[HADRStatus] [nvarchar](50) NOT NULL,
	[ServerAuthentication] [nvarchar](50) NOT NULL,
	[TempDBOptimizedForInMemoryTables] [nvarchar](10) NOT NULL,
	[InMemoryOLTPSupported] [nvarchar](10) NOT NULL,
	[FileStream] [nvarchar](10) NOT NULL,
	[MasterDataFilePath] [nvarchar](255) NOT NULL,
	[MasterDataLogPath] [nvarchar](255) NOT NULL,
	[DefaultDataPath] [nvarchar](255) NULL,
	[DefaultLogPath] [nvarchar](255) NULL,
	[DefaultBackupPath] [nvarchar](255) NULL,
	[DataUpdatedOn] [datetime] NOT NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[tbl_SQLSvcAccounts]    Script Date: 12/16/2024 1:48:39 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tbl_SQLSvcAccounts](
	[ServerName] [nvarchar](100) NOT NULL,
	[ServiceName] [nvarchar](100) NOT NULL,
	[ServiceAccount] [nvarchar](100) NOT NULL,
	[DataUpdatedOn] [datetime] NOT NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[tbl_SQLVersion]    Script Date: 12/16/2024 1:48:39 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tbl_SQLVersion](
	[ServerName] [nvarchar](100) NOT NULL,
	[InstanceName] [nvarchar](100) NOT NULL,
	[InstanceType] [nvarchar](50) NOT NULL,
	[Product] [nvarchar](100) NOT NULL,
	[ProductVersion] [nvarchar](100) NOT NULL,
	[ProductLevel] [nvarchar](50) NOT NULL,
	[DataUpdatedOn] [datetime] NOT NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[tbl_SysAdmins]    Script Date: 12/16/2024 1:48:39 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tbl_SysAdmins](
	[InstanceName] [nvarchar](50) NULL,
	[LoginName] [nvarchar](255) NULL,
	[LoginType] [nvarchar](100) NULL,
	[AccessLevel] [nvarchar](100) NULL,
	[AccessGrantedOn] [datetime] NULL,
	[DataUpdatedOn] [datetime] NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[IndexFragmentationList_New] ADD  DEFAULT (getdate()) FOR [DataCollected]
GO

ALTER TABLE [dbo].[Table_Records] ADD  DEFAULT (getdate()) FOR [DataCollected]
GO

ALTER TABLE [dbo].[tbl_DatabaseBackupDetails] ADD  DEFAULT (getdate()) FOR [DataUpdatedOn]
GO

ALTER TABLE [dbo].[tbl_DatabaseDetails] ADD  DEFAULT (getdate()) FOR [DataUpdatedOn]
GO

ALTER TABLE [dbo].[tbl_DatabaseFileSpace] ADD  DEFAULT (getdate()) FOR [DataUpdatedOn]
GO

ALTER TABLE [dbo].[tbl_DiskDetails] ADD  DEFAULT (getdate()) FOR [DataUpdatedOn]
GO

ALTER TABLE [dbo].[tbl_FailedSQLJobs] ADD  DEFAULT (getdate()) FOR [DataUpdatedOn]
GO

ALTER TABLE [dbo].[tbl_ServerOSDetails] ADD  DEFAULT (getdate()) FOR [DataUpdatedOn]
GO

ALTER TABLE [dbo].[tbl_SQLServerConfigs] ADD  DEFAULT (getdate()) FOR [DataUpdatedOn]
GO

ALTER TABLE [dbo].[tbl_SQLSvcAccounts] ADD  DEFAULT (getdate()) FOR [DataUpdatedOn]
GO

ALTER TABLE [dbo].[tbl_SQLVersion] ADD  DEFAULT (getdate()) FOR [DataUpdatedOn]
GO

ALTER TABLE [dbo].[tbl_SysAdmins] ADD  DEFAULT (getdate()) FOR [DataUpdatedOn]
GO