SQLScripts folder is divided into multiple sub-folder and each folder contains multiple scripts. These scripts requires some changes. Follow the instruction mentioned below and make the changes wherever applicable

Folder - 1_Configure_SQLServerSettings
Script -
	1_Create_EmailOperator.sql
		-> Change the Email Operator name as required
		-> Add the recipient's email address in '@email_address' parameter
	2_Create_DatabaseAlerts.sql
		-> Change the '@operatorName' parameter value to 'Email Operator' name created in previous step
	3_Create_DBMail.sql
		->Change the value of below parameters as applicable
			@DBMailAccountName
			@SMTPServername 
			@emailAddress
			@displayName
			@replyToAddress 
			@port 
			@username 
			@password 
			@profileName 
			@profileDescription
			@recipients
	4_Create_ServerLevelTriggers.sql
		-> NO CHANGE
	5_Configure_SQLServerSetting.sql
		-> Change the value of below variables as applicable
			@minMemory 
			@maxMemory
			@costThreshold 
			@MAXDOP

Folder - 2_Configure_DBAdmin
NO CHANGES REQUIRED

Folder - 3_Create_DBA_Jobs
Script -
	2_Create_DataCollector_Job.sql
		-> Change the value of $instance variable to SQL Instance Name where post installation will take place

Folder - 4_ConfigureTempDB
Script -
	1_Configure_TempDB.sql
		-> Change the value of below parameters as applicable
			@tempdbCurrentDataFilecount 	
			@tempdbNewDataFileCount 	
			@tempdbNewDataFileLocation 	
			@dataFileSizeMB	
			@logFileSizeMB	
			@fileGrowthMB	

