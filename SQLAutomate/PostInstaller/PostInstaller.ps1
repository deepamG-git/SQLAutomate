<#
.SYNOPSIS
    SQL Server Post Installation Script
.DESCRIPTION
    Connects to SQL Server and executes below Scripts in order
    1.Configure SQL Server Settings
    2.Configure DBAdmin Database
    3.Create DB Maintenance/Alerts Jobs
    4.Create Inbound and Outbound Firewall rules for local ports
    
.NOTES
    Author: Deepam Ghosh
    Version: 1.0
#>

#Import Functions
Import-Module $pwd\Logs\Log-Message.ps1
Import-Module $pwd\Logs\Clear-LogFiles.ps1

#Clearing the Log files
Clear-LogFiles

$parametersFile = "$pwd\PostInstaller\PostInstallParameters.txt"

$parameters = @{}
    Get-Content $parametersFile | ForEach-Object {
        if ($_ -match '^([^=]+)=(.+)$') {
            $parameters[$matches[1]] = $matches[2].Trim()
        }
    }

# Hashtable to store parameter names and values
$orderedKeys = @(
    "SQLInstance",
    "Database",
    "UserID",
    "Password",
    "SQLScriptFolder",
    "PsScriptFolder"       
)
    
# Loop through the hashtable and display parameters
Write-Host "`nCheck Below Parameters entered to perform the Post Installation Steps:" -ForegroundColor Yellow
Log-Message "Below are the Post Installer Parameters"
foreach ($key in $orderedKeys) {
    if ($parameters.ContainsKey($key)) {
        Write-Host ("{0,-40}: {1}" -f $key, $Parameters[$key]) -ForegroundColor Yellow
        Log-Message ("{0,-40}: {1}" -f $key, $Parameters[$key])
    }
}

#Confirming from User to Proceed for Installation
do {
    $userInput = Read-Host "`nVerify the parameters above. Confirm to proceed? (y/n)" 
    if ($userInput -eq 'y') { break }
    if ($userInput -eq 'n') { 
        Write-Host "`nPost Installation Aborted." -ForegroundColor Red 
        Log-Message "Post Installation Aborted by User"
        Start-Sleep -Seconds 2
        exit 1
    }

} while ($true)

    # Get all .sql files in the root folder and its subfolders
    $sqlFiles = Get-ChildItem -Path $parameters["SQLScriptFolder"] -Recurse -Filter *.sql

    # Process each SQL file
    foreach ($sqlFile in $sqlFiles) {
        Write-Host "`nExecuting SQL Script --- $($sqlFile.Name)`n" -ForegroundColor Magenta
        Log-Message "Executing SQL Script --- $($sqlFile.Name)"
        Start-Sleep -Seconds 5
        try {
            # Execute the SQL file
            #$output = 
            $result = Invoke-Sqlcmd -ServerInstance $parameters["SQLInstance"] -Database $parameters["Database"] -InputFile $sqlFile.FullName -Username $parameters["UserID"] -Password $parameters["Password"] -Verbose -ErrorAction Stop
            Start-Sleep -Seconds 2
            #Write-Host "`nExecution Completed for SQL Script --- $($sqlFile.Name)" -ForegroundColor Green
            #Log-Message "Execution Completed for SQL Script --- $($sqlFile.Name)"

        }
        catch {
            $errorMessage = $_.Exception.Message
            # Log error
            #Write-Host "`nExecution Failed for SQL Script --- $($sqlFile.Name). $($_.Exception.Message)" -ForegroundColor Red
            #Log-Message "Execution Failed for SQL Script --- $($sqlFile.Name). $($_.Exception.Message)"

        }
        if ($errorMessage){
            Write-Host "`nExecution Failed for SQL Script --- $($sqlFile.Name). `n$($errorMessage)" -ForegroundColor Red
            Log-Message "Execution Failed for SQL Script --- $($sqlFile.Name). $($errorMessage)"
            $errorMessage = $null
        
        }  
        else{
            Write-Host "`nExecution Completed for SQL Script --- $($sqlFile.Name)" -ForegroundColor Green
            Log-Message "Execution Completed for SQL Script --- $($sqlFile.Name)"
        }      
        
    }        
    
    
    # Get all .ps1 files in the folder
    $ps1Files = Get-ChildItem -Path $parameters["PsScriptFolder"] -Recurse -Filter "*.ps1" -File

    foreach ($ps1File in $ps1Files) {
        try {
            Write-Host "`nExecuting: PS Script $($ps1File.FullName)" -ForegroundColor Magenta
            Log-Message "Executing: PS Script $($ps1File.FullName)" 

            # Execute the script
            & $ps1File.FullName

            Write-Host "`nExecution completed for: $($ps1File.FullName)" -ForegroundColor Green
            Log-Message "Execution completed for: $($ps1File.FullName)"
        } 
        catch {
            Write-Host "`nError executing $($ps1File.FullName): $($_.Exception.Message)" -ForegroundColor Red
            Log-Message "Error executing $($ps1File.FullName): $($_.Exception.Message)"
        }
    }
    <#
    Write-Host "`nCreating Inbound Firewall Rules for Local Ports..." -ForegroundColor Magenta
    Start-Sleep -Seconds 5
    .\PostInstaller\Scripts\PS_Scripts\CreateFirewalRule\InboundRule.ps1

    

    Write-Host "`nCreating Outbound Firewall Rules for Local Ports..." -ForegroundColor Magenta
    Start-Sleep -Seconds 5
    .\PostInstaller\Scripts\PS_Scripts\CreateFirewalRule\OutboundRule.ps1
    #>

Write-Host "`nPlease Login into the instance and check if everything is configured properly or not.`nRefer PostInstallation logs stored at below location for details.`n$pwd\Logs\SQLAutomateLogs.txt`n" -ForegroundColor Green
