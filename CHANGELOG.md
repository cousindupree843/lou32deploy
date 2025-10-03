# Changelog

All notable changes to the Lou32 Deployment Protocol will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-10-03

### Added
- Initial release of Lou32 Deployment Protocol
- PowerShell script for enterprise Windows 10/11 configuration (`Setup-DevMachine.ps1`)
- Comprehensive security baseline configuration
  - SMBv1 protocol disabled
  - Windows Defender configuration
  - Windows Firewall enabled for all profiles
  - AutoRun/AutoPlay disabled
  - UAC configuration
  - Remote Desktop security settings
  - Screen saver lock configuration
  - Windows Script Host restrictions
- Windows Package Manager (winget) installation
  - Automatic dependency installation (VCLibs, UI.Xaml)
  - Version verification
- Automated application installation via winget
  - Git, Visual Studio Code, Windows Terminal
  - PowerShell 7, Node.js, Python 3.12
  - Docker Desktop, .NET SDK 8
  - Development tools (Postman, 7-Zip, Notepad++)
  - Web browsers (Chrome, Firefox)
  - Communication tools (Slack, Teams)
- Performance optimizations
  - All visual effects disabled
  - Window animations disabled
  - Transparency disabled
  - Thumbnail previews disabled
  - SysMain (Superfetch) disabled
  - High Performance power plan
  - Hibernation disabled
  - Startup delay removal
  - Windows Search optimization
- UI customization tweaks
  - File extensions visible
  - Hidden files visible
  - Full path in Explorer title bar
  - Quick Access disabled
  - File Explorer opens to "This PC"
  - Bing search disabled in Start Menu
  - Dark Mode enabled
  - Small taskbar icons
  - Task View button hidden
  - People button hidden
  - News and Interests disabled
  - Suggested content disabled
- Privacy and telemetry controls
  - Windows telemetry disabled
  - DiagTrack service disabled
  - dmwappushservice disabled
  - Activity History disabled
  - Location tracking disabled
  - Advertising ID disabled
- Comprehensive logging system
  - Timestamped log entries
  - Color-coded console output
  - Log levels (INFO, WARNING, ERROR, SUCCESS)
  - Desktop log file output
- Error handling and recovery
- Modular function architecture
- Skip parameters for all major sections
- Custom log path support
- Restart prompt at completion
- Detailed documentation
  - README.md with full feature documentation
  - QUICKSTART.md for quick reference
  - ADVANCED-EXAMPLES.ps1 for customization examples
  - applications.config for application management
- .gitignore for PowerShell artifacts
- Changelog for version tracking

### Configuration Options
- `-SkipSecurityBaseline`: Skip security configuration
- `-SkipWingetInstall`: Skip winget installation
- `-SkipAppInstall`: Skip application installation
- `-SkipPerformanceTweaks`: Skip performance optimizations
- `-SkipUITweaks`: Skip UI customizations
- `-LogPath`: Custom log file location

### System Requirements
- Windows 10 (Build 17763+) or Windows 11
- PowerShell 5.1 or higher
- Administrator privileges
- Internet connection for downloads

### Known Limitations
- Requires manual restart to apply all changes
- Some settings may conflict with Group Policy in domain environments
- Windows Script Host disabled by default (may affect legacy scripts)
- File associations require additional configuration

### Security Considerations
- Script requires Administrator privileges
- Review recommended before execution in production
- Some security settings may need organizational adjustment
- Test in VM environment before deployment

## [Unreleased]

### Planned Features
- GUI installer option
- Configuration file support for application lists
- Export/import configuration profiles
- Automated backup before changes
- Rollback capability
- Domain environment detection and adaptation
- Windows 11-specific optimizations
- Additional security hardening options
- Custom branding options
- Remote deployment support
- Silent/unattended mode
- Post-deployment validation tests
- Integration with SCCM/Intune
- Multi-language support

---

## Version History

- **1.0.0** (2024-10-03): Initial release with core functionality

## Support

For issues, questions, or feature requests, please refer to the repository documentation.
