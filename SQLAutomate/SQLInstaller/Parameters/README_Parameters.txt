SetupPath					#SQL Server Installer file path
Environment					#Environment Name. eg. - PROD/DEV			
Features					#Installation Features. Set by default for each Installer Mode. DO NOT CHANGE
SQLInstanceName				#Set MSSQLSERVER if Default Installation, else set NAMED INSTANCE Name
SQLCollation				#SQL Collation Name
SQLRootDir					#Default Root Directory file path. CHANGE AS PER YOUR REQUIREMENT		
SQLBackupDir				#Default Backup Directory file path. CHANGE AS PER YOUR REQUIREMENT					
UserDBDataDir				#Default User Database(s) Data Directory file path. CHANGE AS PER YOUR REQUIREMENT	
UserDBLogDir				#Default User Database(s) Log Directory file path. CHANGE AS PER YOUR REQUIREMENT	
TempDBDataDir				#Default TempDB Data Directory file path. CHANGE AS PER YOUR REQUIREMENT			
TempDBLogDir				#Default TempDB Log Directory file path. CHANGE AS PER YOUR REQUIREMENT			
TempDBFiles					#Initial Number of TempDB Data Files. Default -4. INCREASE THE VALUE IF REQUIRED MORE FILE(s)
TempDBDataFileSize			#Default Size set to 8 MB. If big files are required, use PostInstaller module to increase the size as bigger size set at the time of installation, increase the overall installation time.
TempDBDataFileGrowth			#Default - 128 MB. CHANGE AS PER YOUR REQUIREMENT					
TempDBLogFileSize			#Default Size set to 8 MB. If big files are required, use PostInstaller module to increase the size as bigger size set at the time of installation, increase the overall installation time.
TempDBLogFileGrowth			#Default - 128 MB. CHANGE AS PER YOUR REQUIREMENT		
SAPassword					#Password for SA Account. Set a highly secure password.
SYSAdmAccounts 				#Windows Account which needs SYSADMIN Privileges in SQL Server			
SQLAgentServiceStartType		#SQL Agent Service Type. Default - Automatic. CHANGE AS PER REQUIREMENT
NamedPipes					#Default - 1. CHANGE AS PER REQUIREMENT
InstantFileInitialization	#Default - TRUE. DO NOT CHANGE
SecurityMode				#Default set to MIXED MODE(SQL + Windows. CHANGE AS PER REQUIREMENT
ASCollation					#SSAS Collation Name			
ASDataDir					#Default SSAS Data Directory file path. CHANGE AS PER YOUR REQUIREMENT	
ASLogDir					#Default SSAS Log Directory file path. CHANGE AS PER YOUR REQUIREMENT	
ASBackupDir					#Default SSAS Backup Directory file path. CHANGE AS PER YOUR REQUIREMENT	
ASTempDir					#Default SSAS Temp Directory file path. CHANGE AS PER YOUR REQUIREMENT	
ASConfigDir					#Default SSAS Config Directory file path. CHANGE AS PER YOUR REQUIREMENT	
ASServerMode				#Default set to TABULAR. CHANGE AS PER YOUR REQUIREMENT	 
ASProviderMode				#Default - 1. CHANGE AS PER REQUIREMENT
ASSYSAdmAccounts			#Windows Account which needs SYSADMIN Privileges in SSAS
ASServiceStartType			#SSAS Service Type Default - Automatic. CHANGE AS PER REQUIREMENT
ISServiceStartType			#SSIS Service Type Default - Automatic. CHANGE AS PER REQUIREMENT
RSServiceStartType			#SSRS Service Type Default - Automatic. CHANGE AS PER REQUIREMENT
RSInstallType				#SSRS Install Type. Default - DefaultNativeMode. CHANGE AS PER REQUIREMENT











