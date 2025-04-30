<#
.SYNOPSIS
    SQL Server Automated Installation Script
.DESCRIPTION
    Main Script to Install SQL Server and Perform Post-Installation Steps
    Calls SQLInstaller.ps1 to Install a new SQL Server Instance
    Calls PostInstaller.ps1 to perform the Post SQL Installation Steps

.NOTES
    Author: Deepam Ghosh
    Version: 2.0
#>




#Import Functions
Import-Module $pwd\Logs\Log-Message.ps1
Import-Module $pwd\Logs\Clear-LogFiles.ps1

#Clearing the Log files
Clear-LogFiles

Log-Message "Script Started by User"

#checking if session opened in Admin Mode
$elevated = [bool](([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))

if(-not $elevated){
    $errorMessage = "PowerShell session is not running with elevated privileges. Please 'Run as Administrator'."
    Write-Host "`n$errorMessage`nExiting Now......." -ForegroundColor Red
    Log-Message $errorMessage
    Log-Message "`nProcess aborted by system."
    Start-Sleep -Seconds 5
    exit 1 #Aborted
}

# Notify user that the script is running in admin mode
Write-Host "`nPowerShell session is running with elevated privileges. Continuing execution..." -ForegroundColor Green
Log-Message "PowerShell session is running with elevated privileges. Script execution continues."

Write-Host "`nWelcome to the SQL Automation Module!" -ForegroundColor Magenta


do{
    $Option = Read-Host "`nPlease choose from the below options--`nPress '1' if you want to Install a new SQL Server Instance`nPress '2' if you want to Perform the Post SQL Installation Steps`nor Press Enter to Exit`n"
      
    if($Option -match '^[1-2]$') { break }
    elseif ($Option -eq ''){
        Write-Host "`nProcess Aborted" -ForegroundColor Red
        Write-Host "`nExiting Now......." -ForegroundColor Red
        Log-Message "Process Aborted by User"
        Start-Sleep -Seconds 2
        exit 1 #Aborted
    }
    else {
        Write-Host "`nInvalid input. Please try again." -ForegroundColor Yellow
        Log-Message "Invalid Input Entered by User"
    }
}
while ($true)
    #Write-Host "`nYou have Choosen Option: $Option"
    #Write-Host "`n"

#Install SQL Server
try{
    if($Option -eq 1){
        Write-Host "`nYou have Choosen Option 1 - Install a new SQL Server Instance" -ForegroundColor Green
        Log-Message "User Choose to Install a new SQL Server Instance"
        .\SQLInstaller\SQLInstaller.ps1
        exit 0 #Success
    
    }

    elseif($Option -eq 2){
        Write-Host "`nYou have Choosen Option 2 - Perform the Post SQL Installation Steps`nFollowing Tasks will be Executed in Order.`n1.Configure SQL Server Settings`n2.Configure DBAdmin Database`n3.Create DB Maintenance Jobs`n4.Create Firewall Rules`n" -ForegroundColor Green
        Log-Message "User Choose to Perform the Post SQL Installation Steps"
        .\PostInstaller\PostInstaller.ps1
        exit 0 #Success
    }

}
catch {
    Write-Host "`nAn error occurred while executing the script: $_" -ForegroundColor Red
    Log-Message "An error occurred while executing the script: $_"

}