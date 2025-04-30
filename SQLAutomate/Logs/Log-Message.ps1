

$logFile = "$pwd\Logs\SQLAutomateLogs.txt"

function Log-Message{
    param($Message)
    Add-Content -Path $logFile -Value "$(Get-Date) : $Message"
}

