
#Import Functions
Import-Module $pwd\Logs\Log-Message.ps1
Import-Module $pwd\Logs\Clear-LogFiles.ps1

$ports = @(587) #Outbound local Ports
$ruleName = "MSSQL"

$accessDenied = $false

Write-Host "`nCreating Outbound Firewall Rules for Local Ports...$($ports)" -ForegroundColor Magenta
Start-Sleep -Seconds 5
Log-Message "Creating Outbound Firewall Rules for Local Ports...$($ports)"

try{
    New-NetFirewallRule `
        -DisplayName $ruleName `
        -Direction Outbound `
        -LocalPort $ports `
        -Protocol TCP `
        -Action Allow `
        -Profile Any `
        -ErrorAction Stop
}        
       
catch{

    if ($_.Exception.Message -match "Access is denied"){
        $accessDenied = $true 
        Write-Host "`nError Creating Outbound Firewall Rule. $($_.Exception.Message)" -ForegroundColor Red
        Log-Message "Error Creating Outbound Firewall Rule for Local Ports. $($_.Exception.Message)"
    }
    else{
        Write-Host "`nAn unexpected error occurred: $($_.Exception.Message)" -ForegroundColor Red
        Log-Message "Error Creating Outbound Firewall Rule for Local Ports. $($_.Exception.Message)"
    }
    
}

if(-not $accessDenied){
    Write-Host "`nSuccessfully Created Outbound Firewall Rule - "$($ruleName)" for Local Ports - " $($ports) -ForegroundColor Green
    Log-Message "Creation Compeleted for Outbound Firewall Rules for Local Ports"  
}
    