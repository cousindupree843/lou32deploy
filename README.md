# Lou32 Deployment Protocol

Enterprise Windows Development Machine Configuration Script

## Overview

The Lou32 Deployment Protocol is a comprehensive, enterprise-ready PowerShell script designed to configure fresh Windows 10/11 installations for optimal development environments. This script automates the setup of security baselines, application installations, performance optimizations, and UI customizations.

## Features

### 🔒 Security Baseline Configuration
- Disables SMBv1 protocol (known security vulnerability)
- Enables Windows Defender Real-Time Protection
- Configures Windows Firewall for all profiles
- Disables AutoRun/AutoPlay for all drives
- Configures User Account Control (UAC)
- Sets up secure Remote Desktop settings
- Configures screen saver lock (15-minute timeout)
- Implements security-focused script host restrictions

### 📦 Package Management
- Automatically installs Windows Package Manager (winget) if not present
- Installs all dependencies (VCLibs, UI.Xaml)
- Verifies installation and version

### 💻 Development Tools Installation
Pre-configured to install essential development tools:
- Git
- Visual Studio Code
- Windows Terminal
- PowerShell 7
- Node.js LTS
- Python 3.12
- Docker Desktop
- .NET SDK 8
- Postman
- 7-Zip
- Notepad++
- Google Chrome
- Mozilla Firefox
- Slack
- Microsoft Teams

### ⚡ Performance Optimizations
- Disables all Windows visual effects for maximum performance
- Disables animations, transparency, and window shadows
- Configures SysMain (Superfetch) for SSD optimization
- Sets High Performance power plan
- Disables hibernation to save disk space
- Removes startup delays
- Optimizes Windows Search indexing

### 🎨 UI Tweaks
- Shows file extensions in Explorer
- Shows hidden files
- Displays full path in Explorer title bar
- Opens File Explorer to "This PC" instead of Quick Access
- Enables Dark Mode
- Configures taskbar (small icons, removes unnecessary buttons)
- Disables Bing search in Start Menu
- Disables News and Interests widget
- Removes suggested content

### 🔐 Privacy & Telemetry
- Disables Windows telemetry
- Stops DiagTrack and dmwappushservice services
- Disables Activity History
- Disables location tracking
- Disables advertising ID

## Requirements

- **Operating System**: Windows 10 (version 1809 or higher) or Windows 11
- **PowerShell**: Version 5.1 or higher
- **Privileges**: Administrator rights required
- **Internet Connection**: Required for downloading winget and applications

## Installation & Usage

### Quick Start

1. **Download the script** to your local machine
2. **Open PowerShell as Administrator**
3. **Navigate to the script directory**
4. **Run the script**:

```powershell
.\Setup-DevMachine.ps1
```

### Execution Policy

If you encounter execution policy restrictions, run:

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
.\Setup-DevMachine.ps1
```

### Advanced Usage

The script supports several parameters to customize the execution:

```powershell
# Skip specific configuration sections
.\Setup-DevMachine.ps1 -SkipAppInstall

# Skip multiple sections
.\Setup-DevMachine.ps1 -SkipAppInstall -SkipPerformanceTweaks

# Specify custom log path
.\Setup-DevMachine.ps1 -LogPath "C:\Logs\deployment.txt"
```

### Available Parameters

| Parameter | Description |
|-----------|-------------|
| `-SkipSecurityBaseline` | Skip security baseline configuration |
| `-SkipWingetInstall` | Skip winget installation |
| `-SkipAppInstall` | Skip application installation |
| `-SkipPerformanceTweaks` | Skip performance optimizations |
| `-SkipUITweaks` | Skip UI customizations |
| `-LogPath` | Custom path for log file (default: Desktop) |

### Examples

```powershell
# Full configuration with all features
.\Setup-DevMachine.ps1

# Only install applications, skip other configurations
.\Setup-DevMachine.ps1 -SkipSecurityBaseline -SkipPerformanceTweaks -SkipUITweaks

# Configure everything except applications
.\Setup-DevMachine.ps1 -SkipAppInstall

# Custom log location
.\Setup-DevMachine.ps1 -LogPath "C:\DeploymentLogs\setup-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
```

## What Gets Installed

### Development Tools
- **Git**: Version control system
- **Visual Studio Code**: Code editor
- **Windows Terminal**: Modern terminal application
- **PowerShell 7**: Latest PowerShell version
- **Node.js LTS**: JavaScript runtime
- **Python 3.12**: Programming language
- **Docker Desktop**: Container platform
- **.NET SDK 8**: .NET development framework

### Utilities
- **7-Zip**: File archiver
- **Notepad++**: Advanced text editor
- **Postman**: API development tool

### Browsers
- **Google Chrome**: Web browser
- **Mozilla Firefox**: Web browser

### Communication
- **Slack**: Team communication
- **Microsoft Teams**: Collaboration platform

## Logging

The script generates a detailed log file with timestamps for all operations. By default, the log is saved to:

```
%USERPROFILE%\Desktop\Lou32Deploy-Log.txt
```

The log includes:
- Timestamp for each operation
- Log levels (INFO, WARNING, ERROR, SUCCESS)
- Detailed error messages
- Installation results

## Post-Installation

After running the script:

1. **Review the log file** for any errors or warnings
2. **Restart your computer** to apply all changes (recommended)
3. **Verify installations** by checking the installed applications
4. **Configure applications** according to your specific needs

## Customization

### Modifying Application List

To customize which applications get installed, edit the `$applications` array in the `Install-Applications` function:

```powershell
$applications = @(
    @{Name="Application Name"; Id="Winget.PackageId"},
    # Add more applications here
)
```

### Finding Winget Package IDs

To find package IDs for other applications:

```powershell
winget search "application name"
```

### Adding Custom Configuration

The script is modular and well-commented. You can add custom functions following the existing pattern:

1. Create a new function in the appropriate section
2. Add it to the `Main` function execution flow
3. Optionally add a skip parameter

## Security Considerations

- The script requires **Administrator privileges** to make system-level changes
- Review the script before execution to understand all changes
- Security settings follow enterprise best practices
- Some settings (like disabling WSH) may need adjustment based on your requirements
- Consider testing in a VM or non-production environment first

## Troubleshooting

### Script Won't Run
- Ensure you're running PowerShell as Administrator
- Check execution policy: `Get-ExecutionPolicy`
- Temporarily bypass: `Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process`

### Winget Installation Fails
- Ensure you have an active internet connection
- Check Windows version (must be 1809 or higher)
- Try installing Microsoft Store apps manually first

### Application Installation Issues
- Check the log file for specific errors
- Verify internet connectivity
- Some applications may require manual acceptance of licenses
- Retry failed installations manually: `winget install --id <PackageId>`

### Changes Not Applied
- Restart Windows Explorer: `Stop-Process -Name explorer -Force`
- Log out and log back in
- Restart the computer

## System Impact

### Disabled Services
- SMBv1 Protocol
- SysMain (Superfetch)
- DiagTrack
- dmwappushservice

### Disabled Features
- Windows Script Host (for security)
- Hibernation
- Cortana
- Various telemetry services

### Modified Settings
- Visual effects (all disabled)
- Power plan (High Performance)
- UI preferences
- File Explorer defaults
- Privacy settings

## Compatibility

| Operating System | Status |
|-----------------|--------|
| Windows 11 (all versions) | ✅ Fully Supported |
| Windows 10 22H2 | ✅ Fully Supported |
| Windows 10 21H2 | ✅ Fully Supported |
| Windows 10 21H1 | ✅ Fully Supported |
| Windows 10 20H2 | ✅ Fully Supported |
| Windows 10 1809+ | ✅ Supported |
| Windows 10 <1809 | ❌ Not Supported |

## Contributing

To contribute improvements or report issues:
1. Test changes thoroughly in a VM environment
2. Ensure backward compatibility
3. Document all changes
4. Follow existing code style and commenting patterns

## License

This script is provided as-is for deployment purposes. Review and test before using in production environments.

## Version History

### v1.0.0 (Current)
- Initial release
- Security baseline configuration
- Winget installation and application management
- Performance optimizations
- UI customization
- Privacy and telemetry controls
- Comprehensive logging
- Modular architecture with skip parameters

## Support

For issues, questions, or feature requests, please refer to the repository documentation.

## Acknowledgments

Built following Microsoft's best practices and enterprise deployment standards.

---

**⚠️ Important Notes:**
- Always test in a non-production environment first
- Review the script to understand all changes before execution
- Some settings may require adjustment based on organizational policies
- A system restart is recommended after running the script
- Keep a backup of important data before making system-level changes
