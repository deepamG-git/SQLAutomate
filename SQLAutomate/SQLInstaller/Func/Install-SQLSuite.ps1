<#
.SYNOPSIS
    SQL Server Automated Installation Script
.DESCRIPTION
    Installs SQL Server Database Engine, SSAS, SSRS, SSIS with user-supplied parameters. Logs are saved for debugging.
.PARAMETER Parameters
    Array of SQL installation parameters.
.NOTES
    Author: Deepam Ghosh
    Version: 2.0
#>

Import-Module $pwd\Logs\Log-Message.ps1
$standardOutputFile = "$pwd\Logs\StandardOutput.txt"

function Install-SQLSuite{
    param (
        [hashtable]$validatedParameters
        )
     
    #Mounting SQL Server Image ISO
    try{
        Write-Host "`nMounting SQL Server Image....." -ForegroundColor Magenta
        Log-Message "Mounting SQL Server Image....."
        $drive = Mount-DiskImage -ImagePath $validatedParameters["SetupPath"]
        Write-Host "`nMount Successfull" -ForegroundColor Green
        Log-Message "Mount Successfull"
        Write-Host "`nGetting Disk drive of the mounted image" -ForegroundColor Magenta
        Log-Message "Getting Disk drive of the mounted image"
        $disks = Get-WmiObject -Class Win32_logicaldisk -Filter "DriveType = '5'"
        foreach ($disk in $disks){
            $driveLetter = $disk.DeviceID
        }
    }
    catch{
        Write-Host "`nMount Failed" -ForegroundColor Red
        Log-Message "Moun Failed"
    }

    if($driveLetter) {

        try{
            Write-Host "`nStarting SQL Installation......." -ForegroundColor Magenta
            Log-Message "Starting SQL Installation......."

            $setupPath = "$driveLetter\Setup.exe"
        
            $arguments = "/ACTION=Install /IACCEPTSQLSERVERLICENSETERMS /QS /INSTANCENAME=$($validatedParameters['SQLInstanceName']) /INSTANCEID=$($validatedParameters['SQLInstanceName']) /SQLCOLLATION=$($validatedParameters['SQLCollation']) /INSTALLSQLDATADIR=$($validatedParameters['SQLRootDir']) /SQLBACKUPDIR=$($validatedParameters['SQLBackupDir']) /SQLUSERDBDIR=$($validatedParameters['UserDBDataDir']) /SQLUSERDBLOGDIR=$($validatedParameters['UserDBLogDir']) /SQLTEMPDBDIR=$($validatedParameters['TempDBDataDir']) /SQLTEMPDBLOGDIR=$($validatedParameters['TempDBLogDir']) /SQLTEMPDBFILECOUNT=$($validatedParameters['TempDBFiles']) /SQLTEMPDBFILESIZE=$($validatedParameters['TempDBDataFileSize']) /SQLTEMPDBFILEGROWTH=$($validatedParameters['TempDBDataFileGrowth']) /SQLTEMPDBLOGFILESIZE=$($validatedParameters['TempDBLogFileSize']) /SQLTEMPDBLOGFILEGROWTH=$($validatedParameters['TempDBLogFileGrowth']) /FEATURES=$($validatedParameters['Features']) /SAPWD=$($validatedParameters['SAPassword']) /SQLSYSADMINACCOUNTS=$($validatedParameters['SYSAdmAccounts']) /SQLSVCSTARTUPTYPE=$($validatedParameters['SQLServiceStartType']) /AGTSVCSTARTUPTYPE=$($validatedParameters['SQLAgentServiceStartType']) /TCPENABLED=$($validatedParameters['TCP']) /NPENABLED=$($validatedParameters['NamedPipes']) /SQLSVCINSTANTFILEINIT=$($validatedParameters['InstanceFileInitialization']) /SECURITYMODE=$($validatedParameters['SecurityMode']) /ASCOLLATION=$($validatedParameters['ASCollation']) /ASDATADIR=$($validatedParameters['ASDataDir']) /ASLOGDIR=$($validatedParameters['ASLogDir']) /ASBACKUPDIR=$($validatedParameters['ASBackupDir']) /ASTEMPDIR=$($validatedParameters['ASTempDir']) /ASCONFIGDIR=$($validatedParameters['ASConfigDir']) /ASSYSADMINACCOUNTS=$($validatedParameters['ASSYSAdmAccounts']) /ASSERVERMODE=$($validatedParameters['ASServerMode']) /ASPROVIDERMSOLAP=$($validatedParameters['ASProviderMode']) /ASSVCSTARTUPTYPE=$($validatedParameters['ASServiceStartType']) /RSINSTALLMODE=$($validatedParameters['RSInstallType']) /RSSVCSTARTUPTYPE=$($validatedParameters['RSServiceStartType']) /ISSVCSTARTUPTYPE=$($validatedParameters['ISServiceStartType'])"

            $process = Start-Process -Wait $setupPath -ArgumentList $arguments -RedirectStandardOutput $standardOutputFile -PassThru

            if($process.ExitCode -eq 0){
                Write-Host "`nSQL Suite(DBEngine,SSAS,SSRS,SSIS) Installation Completed Successfully!!`nReboot Pending.`nSQL Server, SQL Server Agent, Analysis, Reporting, Integration Services are currently configured with Default local acccount. Please change it Domain Service Account." -ForegroundColor Green
                Log-Message "SQL Suite(DBEngine,SSAS,SSRS,SSIS) Installation Completed Successfully."
		Log-Message "Reboot Pending."
            }
            else{
                Write-Host "`nSQL Installation Failed" -ForegroundColor Red
                Log-Message "SQL Installation Failed"
            }
        }
        catch{
            $errorMessage = $_.Exception.Message
            Write-Host "`nSQL Installation Failed: $($_.Exception.Message)" -ForegroundColor Red
            Log-Message $errorMessage

        }
        finally{
            Write-Host "`nImportant!! -- Please review the Logs stored at below location irrespective of Installation failed or successfull
            1. $pwd\Logs\StandardOutput.txt
            2. $pwd\Logs\SQLAutomationLog.txt
            3. C:\Program Files\Microsoft SQL Server\XXX\Setup Bootstrap\Log\Summary.txt
            " -ForegroundColor Magenta
            Log-Message "Important!! -- Please review the Logs stored at below location irrespective of Installation failed or successfull
            1. $pwd\Logs\StandardOutput.txt
            2. $pwd\Logs\SQLAutomationLog.txt
            3. C:\Program Files\Microsoft SQL Server\XXX\Setup Bootstrap\Log\Summary.txt"
        }         
        
        try{
            Write-Host "`nUnMounting SQL Server Image......." -ForegroundColor Magenta
            Log-Message "UnMounting SQL Server Image"
            Dismount-DiskImage -InputObject $drive
            Write-Host "`nUnMount Successfull" -ForegroundColor Green
            Log-Message "UnMount Successfull"
        }
        catch{
            $errorMessage = $_.Exception.Message
            Write-Host "`nUnMount Failed: $($_.Exception.Message)" -ForegroundColor Red
            Log-Message $errorMessage
        }    
        
    }
}