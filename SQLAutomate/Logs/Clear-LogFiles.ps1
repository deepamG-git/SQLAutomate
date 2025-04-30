

function Clear-LogFiles{
    # Define log file paths
        $logFiles = @(
        "$pwd\Logs\StandardOutput.txt",
        "$pwd\Logs\SQLAutomateLogs.txt"
        )

    # Clear each log file
    foreach ($logFile in $logFiles) {
        if (Test-Path $logFile) {
            try {
                Clear-Content -Path $logFile -Force
               # Write-Host "Cleared log file: $logFile" -ForegroundColor Green
            } catch {
               # Write-Host "Failed to clear log file: $logFile. Error: $($_.Exception.Message)" -ForegroundColor Red
            }
        } else {
            Write-Host "Log file not found: $logFile. Skipping." -ForegroundColor Yellow
        }
    }
}