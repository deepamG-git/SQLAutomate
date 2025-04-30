<#
.SYNOPSIS
    SQL Server Automated Installation Script
.DESCRIPTION
    Validates Parameters Entered for Installation
    Displays the Parameters in the console after Validation
    Return the Parameters Hashtable to the SQLInstaller.ps1 main script
.NOTES
    Author: Deepam Ghosh
    Version: 1.0
#>

function Validate-ParametersSQLDBEngine {
    param (
        [string[]]$parameterFilepath
    )
    
    # Load key-value pairs into a hashtable
    $Parameters = @{}
    Get-Content $ParameterFilePath | ForEach-Object {
        if ($_ -match '^([^=]+)=(.+)$') {
            $parameters[$matches[1]] = $matches[2].Trim()
        }
    }
    
Write-Host "Validating parameters.....`n" -ForegroundColor Magenta

    # Validation for each parameter
    if (-not $Parameters["SetupPath"]) { Write-Error "Error: SQL Setup Path is missing."; return $null}
    if (-not (Test-Path $Parameters["SetupPath"])) { Write-Error "Error: SQL Setup Path does not exist: $($Parameters["SetupPath"])." ;return $null }

    if (-not $Parameters["Environment"]) { Write-Error "Error: Environment is missing."; return $null  }
    if (-not $Parameters["Features"]) { Write-Error "Error: SQL Features are missing.";return $null   }
    if (-not $Parameters["SQLInstanceName"]) { Write-Error "Error: SQL Instance Name is required.";return $null   }

    if (-not $Parameters["SQLCollation"]) { Write-Error "Error: SQL Collation is missing.";return $null   }

    # Directory path validations
    $directories = @(
        @{Name = "SQLRootDir"; Value = $Parameters["SQLRootDir"]},
        @{Name = "SQLBackupDir"; Value= $Parameters["SQLBackupDir"]},
        @{Name = "UserDBDataDir"; Value=$Parameters["UserDBDataDir"]},
        @{Name = "UserDBLogDir"; Value=$Parameters["UserDBLogDir"]},
        @{Name = "TempDBDataDir"; Value=$Parameters["TempDBDataDir"]},
        @{Name = "TempDBLogDir"; Value=$Parameters["TempDBLogDir"]}
    )
    foreach ($dir in $directories) {
        if (-not $dir.Value) {
            Write-Error "Error: $($dir.Name) is missing."; return $null 
        }
    }

    # Numeric parameter validations
    $numericParams = @(
        @{Name = "TempDBFiles"; Value = $Parameters["TempDBFiles"]},
        @{Name = "TempDBDataFileSize" ;Value = $Parameters["TempDBDataFileSize"]},
        @{Name = "TempDBDataFileGrowth"; Value = $Parameters["TempDBDataFileGrowth"]},
        @{Name = "TempDBLogFileSize"; Value = $Parameters["TempDBLogFileSize"]},
        @{Name = "TempDBLogFileGrowth"; Value = $Parameters["TempDBLogFileGrowth"]}
    )
    foreach ($param in $numericParams) {
        if (-not $param.Value){
            Write-Error "Error: $($param.Name) is missing.";return $null 
        }
        if ($param.Value -notmatch '^\d+$') {
            Write-Error "Error: $($param.Name) must be a positive integer."; return $null 
        }
    }

    # Password validation
    if (-not $Parameters["SAPassword"]) { Write-Error "Error: SA Password is missing."; return $null  }
    if ($Parameters["SAPassword"].Length -lt 8) { Write-Error "Error: SA Password must be at least 8 characters."; return $null  }

    if (-not $Parameters["SYSAdmAccounts"]) {Write-Error "Error: SQL Sysadmin Accounts are missing. Atleast Once account should have SysAdmin access."; return $null}

      # Start type validation (must be Manual, Automatic, or Disabled)
    $validStartTypes = @("Automatic", "Manual", "Disabled")
    if ($Parameters["SQLServiceStartType"] -notin $validStartTypes) {
        Write-Error "Error: SQL Service Start Type must be one of: Automatic, Manual, Disabled.";return $null  
    }
    if ($Parameters["SQLAgentServiceStartType"] -notin $validStartTypes) {
        Write-Error "Error: SQL Agent Service Start Type must be one of: Automatic, Manual, Disabled."; return $null 
    }

    if (-not $Parameters["TCP"]) { Write-Error "Error:TCP Value is missing.";return $null   }
    if ($Parameters["TCP"] -ne 1)  {Write-Error "Error: TCP Value should be 1.";return $null }

    if (-not $Parameters["NamedPipes"]) { Write-Error "Error:Named Pipes Value is missing."; return $null  }
    if ($Parameters["NamedPipes"] -ne 0)  {Write-Error "Error: Named Pipes Value should be 0."; return $null }
    
    if (-not $Parameters["InstantFileInitialization"]) { Write-Error "Error: InstantFileInitialization Value is missing.";  return $null }
    if ($Parameters["InstantFileInitialization"] -ne "TRUE") {Write-Error "Error: Instant File Initialization should be TRUE."; return $null }

    if (-not $Parameters["SecurityMode"]) { Write-Error "Error: SecurityMode Value is missing."; return $null  }
    if($Parameters["SecurityMode"] -ne "SQL") {Write-Error "Error: Security Mode should be SQL(Mixed Mode).";return $null }
    
    #$instanceID = $Parameters["InstanceName"]

       
    # Hashtable to store parameter names and values
    $orderedKeys = @(
        "SetupPath",                         
        "Environment" ,                      
        "Features", 
        "SQLInstanceName",
        "SQLCollation",
        "SQLRootDir",
        "SQLBackupDir" ,      
        "UserDBDataDir",
        "UserDBLogDir",
        "TempDBDataDir",
        "TempDBLogDir",
        "TempDBFiles",
        "TempDBDataFileSize",
        "TempDBDataFileGrowth", 				
        "TempDBLogFileSize",
        "TempDBLogFileGrowth", 
        "SAPassword",
        "SYSAdmAccounts",
        "SQLServiceStartType",				
        "SQLAgentServiceStartType",
        "TCP",
        "NamedPipes",
        "InstantFileInitialization",
        "SecurityMode"
    )
    

    Start-Sleep -Seconds 5
    Write-Host "Parameter validation passed successfully." -ForegroundColor Green

    # Loop through the hashtable and display parameters
    Write-Host "`nBelow are the parameters entered for SQL Installation`n" -ForegroundColor Yellow
    foreach ($key in $orderedKeys) {
        if ($Parameters.ContainsKey($key)) {
            Write-Host ("{0,-40}: {1}" -f $key, $Parameters[$key]) -ForegroundColor Yellow
        }
    }

    return $Parameters


}


#Validate-ParametersSQLDBEngine 'C:\Users\PAM-Deepam.Ghosh\Desktop\SQLAutomate\SQLInstaller\Parameters\SQLDBEngine_Install_Parameters.txt'
