<#
.SYNOPSIS
    SQL Server Automated Installation Script
.DESCRIPTION
    Main Script to Install SQL Server bases on User Input(Only DB Engine or DBEngine, SSRS, SSAS and SSIS)
    Calls Validate-Parameters_DBEngine.ps1 to Validate the Parameters entered for Installation
    Calls Install-SQL_DBEngine.ps1 to Install the SQL Server
.NOTES
    Author: Deepam Ghosh
    Version: 2.0
#>

#Import Functions
Import-Module $pwd\SQLInstaller\Func\Validate-Parameters_SQLDBEngine.ps1
Import-Module $pwd\SQLInstaller\Func\Validate-Parameters_SQLSuite.ps1
Import-Module $pwd\SQLInstaller\Func\Install-SQLDBEngine.ps1
Import-Module $pwd\SQLInstaller\Func\Install-SQLSuite.ps1
Import-Module $pwd\Logs\Log-Message.ps1

#$Error.Clear()

Write-Host "`nSQL Server Installation will start now...." -ForegroundColor Magenta
Log-Message "SQL Server Installation will start now...."

#Taking User Input from User for Installation Type
do{
    $InstallType = Read-Host "`nPress 1 if you want to Install SQL DBEngine Only`nPress 2 if you want to Install SQL Suite(DBEngine,SSAS,SSRS,SSIS)`nor Press Enter to Exit`n"
    if($InstallType -match '^[1-2]$') { break }
    elseif ($InstallType -eq ''){
        Write-Host "`nSQL Installation Aborted" -ForegroundColor Red
        Write-Host "`nExiting Now......." -ForegroundColor Red
        Log-Message "SQL Installation Aborted by User"
        Start-Sleep -Seconds 2
        exit 1 #Aborted
    }
    else {
        Write-Host "`nInvalid input. Please try again." -ForegroundColor Yellow
        Log-Message "Invalid Input Entered by User"
    }
}
while($true)
    #Write-Host "`nYou have Choosen Option: $InstallType"
   
try{

    #When User Chooses to Install Only MSSQL - Option 1
    if($InstallType -eq 1){
        Write-Host "`nYou have Choosen Option 1 - Install SQL DBEngine`n" -ForegroundColor Green
        Log-Message "User Choose Option 1 - Install SQL DBEngine"

        #DB Engine Installation Parameters
        $parameterFile = "$pwd\SQLInstaller\Parameters\SQLDBEngine_Install_Parameters.txt"
            
        $validatedParameters = Validate-ParametersSQLDBEngine -parameterFilepath $parameterFile

        if($null -eq $validatedParameters){
            Write-Host "`nParameter Validation failed. Exiting......." -ForegroundColor Red
            Log-Message "Parameter Validation Failed"
            Start-Sleep -Seconds 2
            exit 1
        }

        else{
            Log-Message "Parameter Validation Successfull"
        }
        
        #Confirming from User to Proceed for Installation
        do {
            $userInput = Read-Host "`nVerify the parameters above. Confirm installation? (y/n)" 
            if ($userInput -eq 'y') { break }
            if ($userInput -eq 'n') { 
                Write-Host "`nInstallation Aborted." -ForegroundColor Red 
                Log-Message "Installation Aborted by User"
                Start-Sleep -Seconds 2
                exit 1
            }
        } while ($true)

        
        Write-Host "`nProceeding with Installation......." -ForegroundColor Magenta
        Log-Message "Proceeding with Installation......."
        Start-Sleep -Seconds 2
        
        Install-SQLDBEngine $validatedParameters

        exit 0 #Success

    }



    elseif($InstallType -eq 2){
        Write-Host "`nYou have Choosen Option 2 - Install SQL Suite(DBEngine,SSAS,SSRS,SSIS)`n" -ForegroundColor Green
        Log-Message "User Choose Option 2 - Install SQL Suite(DBEngine,SSAS,SSRS,SSIS)"

        #DB Engine Installation Parameters
        $parameterFile = "$pwd\SQLInstaller\Parameters\SQLSuite_Install_Parameters.txt"
            
        $validatedParameters = Validate-ParametersSQLSuite -parameterFilepath $parameterFile

        if($null -eq $validatedParameters){
            Write-Host "`nParameter Validation failed. Exiting..." -ForegroundColor Red
            Log-Message "Parameter Validation Failed"
            Start-Sleep -Seconds 2
            exit 1
        }

        else{
            Log-Message "Parameter Validation Successfull"
        }
        
        #Confirming from User to Proceed for Installation
        do {
            $userInput = Read-Host "`nVerify the parameters above. Confirm installation? (y/n)" 
            if ($userInput -eq 'y') { break }
            if ($userInput -eq 'n') { 
                Write-Host "`nInstallation Aborted." -ForegroundColor Red 
                Log-Message "Installation Aborted by User"
                Start-Sleep -Seconds 2
                exit 1
            }
        } while ($true)

        
        Write-Host "`nProceeding with Installation......." -ForegroundColor Magenta
        Log-Message "Proceeding with Installation......."
        Start-Sleep -Seconds 2
        
        Install-SQLSuite $validatedParameters

        exit 0 #Success

    }
}
catch {
    Write-Host "`nAn error occurred while executing the script: $_" -ForegroundColor Red
    Log-Message "An error occurred while executing the script: $_"
    Write-Host "`nExiting......." -ForegroundColor Red
    Start-Sleep -Seconds 2
}