
#Import Functions
Import-Module $pwd\Logs\Log-Message.ps1
Import-Module $pwd\Logs\Clear-LogFiles.ps1

$ports = @(1433,1434,5022,443,80,2383) #InBound Local Ports
$ruleName = "MSSQL"

$accessDenied = $false

Write-Host "`nCreating Inbound Firewall Rules for Local Ports...$($ports)" -ForegroundColor Magenta
Log-Message "Creating Inbound Firewall Rules for Local Ports...$($ports)"
Start-Sleep -Seconds 5

try{
    New-NetFirewallRule `
        -DisplayName $ruleName `
        -Direction Inbound `
        -LocalPort $ports `
        -Protocol TCP `
        -Action Allow `
        -Profile Any `
        -ErrorAction Stop
}        

catch{

    if ($_.Exception.Message -match "Access is denied"){
        $accessDenied = $true 
        Write-Host "`nError Creating Inbound Firewall Rule. $($_.Exception.Message)" -ForegroundColor Red
        Log-Message "Error Creating Inbound Firewall Rule for Local Ports. $($_.Exception.Message)"
    }
    else{
        Write-Host "`nAn unexpected error occurred: $($_.Exception.Message)" -ForegroundColor Red
        Log-Message "Error Creating Inbound Firewall Rule for Local Ports. $($_.Exception.Message)"
    }
    
}

if(-not $accessDenied){
    Write-Host "`nSuccessfully Created Inbound Firewall Rule - "$($ruleName)" for Local Ports - " $($ports) -ForegroundColor Green
    Log-Message "Creation Compeleted for Inbound Firewall Rules for Local Ports"  
}
    