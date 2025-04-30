# SQLAutomate
SQL Automate - A DBA's Time-Saving Toolkit

**SQLAutomate** is a lightweight PowerShell-based tool designed to simplify and automate the installation and configuration of Microsoft SQL Server
 across multiple servers. It helps DBAs save time, ensure consistency, and eliminate the pain of repetitive manual setups.

## Features

- One-click **SQL Server installation**
- Support for:
  - Standalone DB Engine
  - Full SQL Suite (SSIS, SSAS, SSRS)
- **Post-installation automation** including:
  - TempDB configuration
  - Email alerts, operators, and database mail
  - Memory/CPU optimization
  - Database Maintenance Jobs
  - Custom DBAdmin database setup
  - SQL metadata collection
  - Firewall rule configuration

## Prerequisites

- Windows OS
- PowerShell 5.1 or higher
- SQL Server ISO file (installer)

## How to Use

### 1. SQL Server Installation

- Edit parameters in:
  - `SQLDBEngine_Install_Parameters.txt` for DB Engine only
  - `SQLSuite_Install_Parameters.txt` for full SQL Suite
- Run `master.ps1` with **Admin PowerShell** and choose option `1`
- Follow the prompts and review logs in `/Logs` folder

### 2. Post-Installation Configuration

- Edit scripts in `PostInstaller\Scripts` as needed
- Modify `PostInstallParameters.txt`
- Run `master.ps1` and choose option `2`
- Follow on-screen prompts

## Notes

- Keep parameter files **strictly formatted**
- If you want to skip any post-install task, just remove the relevant script from the folder

## Logs

- All actions are logged in:  
  `SQLAutomate\Logs\SQLAutomate.log`

## Contact

Created by Deepam Ghosh  
For questions or contributions, open an [issue](https://github.com/your-username/SQLAutomate/issues) or reach out at: [deepam.ghosh01@gmail.com]

## License

MIT License. See `LICENSE` file for details.
