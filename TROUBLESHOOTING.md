# Lou32 Deployment Protocol - Troubleshooting Guide

This guide provides solutions to common issues you may encounter when running the Lou32 Deployment Protocol.

## Table of Contents
- [Prerequisites & Permissions](#prerequisites--permissions)
- [Script Execution Issues](#script-execution-issues)
- [Winget Installation Issues](#winget-installation-issues)
- [Application Installation Issues](#application-installation-issues)
- [Registry & Configuration Issues](#registry--configuration-issues)
- [Performance Issues](#performance-issues)
- [Rollback & Recovery](#rollback--recovery)
- [Advanced Troubleshooting](#advanced-troubleshooting)

---

## Prerequisites & Permissions

### Issue: "Script cannot be loaded because running scripts is disabled"

**Cause**: PowerShell execution policy prevents script execution.

**Solution 1** (Temporary - Recommended for first run):
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
.\Setup-DevMachine.ps1
```

**Solution 2** (Permanent - Current User):
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
.\Setup-DevMachine.ps1
```

**Solution 3** (Check current policy):
```powershell
Get-ExecutionPolicy -List
```

### Issue: "The term 'Setup-DevMachine.ps1' is not recognized"

**Cause**: Not in the correct directory or wrong path.

**Solution**:
```powershell
# Check current directory
Get-Location

# Navigate to script location
cd C:\Path\To\Script

# Or run with full path
C:\Path\To\Script\Setup-DevMachine.ps1
```

### Issue: "Administrator privileges required"

**Cause**: Script must run as Administrator.

**Solution**:
1. Close current PowerShell window
2. Right-click PowerShell icon
3. Select "Run as Administrator"
4. Navigate to script and run again

**Verify Admin Status**:
```powershell
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
Write-Host "Running as Admin: $isAdmin"
```

---

## Script Execution Issues

### Issue: Script hangs or appears frozen

**Cause**: Long-running operation or network timeout.

**Solution**:
1. Wait for current operation to complete (some operations take 5-10 minutes)
2. Check the log file for the last operation
3. Check internet connection
4. Press `Ctrl+C` to cancel if truly stuck

**Check Progress**:
```powershell
# In another PowerShell window, monitor the log
Get-Content "$env:USERPROFILE\Desktop\Lou32Deploy-Log.txt" -Wait -Tail 10
```

### Issue: Script exits with errors

**Cause**: Various - check log file for details.

**Solution**:
1. Review the log file: `$env:USERPROFILE\Desktop\Lou32Deploy-Log.txt`
2. Look for `[ERROR]` entries
3. Address specific errors (see sections below)
4. Re-run script with skip parameters to skip completed sections:
   ```powershell
   .\Setup-DevMachine.ps1 -SkipSecurityBaseline -SkipWingetInstall
   ```

### Issue: "Access Denied" errors during execution

**Cause**: Insufficient permissions or file in use.

**Solution**:
1. Ensure running as Administrator
2. Close all applications that might lock files
3. Disable antivirus temporarily (if it's blocking changes)
4. Check Windows Defender exclusions

---

## Winget Installation Issues

### Issue: Winget installation fails with "Cannot find path"

**Cause**: Missing dependencies or Windows version too old.

**Solution**:
```powershell
# Check Windows version
Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, OsBuildNumber

# Manual winget installation:
# 1. Open Microsoft Store
# 2. Search for "App Installer"
# 3. Click Update/Install
```

### Issue: "Add-AppxPackage: Deployment failed"

**Cause**: Corrupted download or permission issues.

**Solution**:
```powershell
# Clear temp files
Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue

# Re-register Windows Store
Get-AppXPackage *WindowsStore* -AllUsers | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}

# Retry script
.\Setup-DevMachine.ps1 -SkipSecurityBaseline -SkipPerformanceTweaks -SkipUITweaks -SkipAppInstall
```

### Issue: Winget command not found after installation

**Cause**: PATH not updated or installation incomplete.

**Solution**:
```powershell
# Refresh environment variables
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Restart PowerShell
# Or manually find winget:
Get-ChildItem -Path "$env:LOCALAPPDATA\Microsoft\WindowsApps" -Filter "winget.exe" -Recurse
```

---

## Application Installation Issues

### Issue: Some applications fail to install

**Cause**: Network issues, package not found, or conflicts.

**Solution**:

**Step 1**: Check which apps failed in the log file

**Step 2**: Install manually:
```powershell
# Search for the package
winget search "application name"

# Install with verbose output
winget install --id PackageId --verbose
```

**Step 3**: Common specific fixes:

**Docker Desktop**:
- Requires Windows 10 Pro/Enterprise or Windows 11
- Enable Hyper-V: `Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All`
- Enable WSL2: `wsl --install`

**Visual Studio Code**:
```powershell
winget install --id Microsoft.VisualStudioCode --override '/SILENT /mergetasks=!runcode,addcontextmenufiles,addcontextmenufolders'
```

**Node.js or Python** (PATH issues):
```powershell
# After installation, refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
```

### Issue: "Package agreements" error

**Cause**: Interactive prompts need acceptance.

**Solution**:
The script already uses `--accept-package-agreements` flag, but if still prompted:
```powershell
winget install --id PackageId --accept-package-agreements --accept-source-agreements
```

### Issue: Application installed but not working

**Cause**: Needs restart or environment variables not loaded.

**Solution**:
1. Restart PowerShell/Terminal
2. Restart Windows Explorer: `taskkill /f /im explorer.exe & start explorer`
3. Restart computer
4. Reinstall the specific application

---

## Registry & Configuration Issues

### Issue: Registry changes not applying

**Cause**: Need restart or Explorer refresh.

**Solution**:
```powershell
# Restart Explorer
taskkill /f /im explorer.exe
Start-Process explorer.exe

# Force registry flush
# Log out and log back in
# Or restart computer
```

### Issue: "Registry key not found" errors

**Cause**: Key doesn't exist on this Windows version.

**Solution**: This is normal for some optional tweaks. The script uses `-ErrorAction SilentlyContinue` to handle this. Check the log to see if it's causing actual problems.

### Issue: Changes reversed after restart

**Cause**: Group Policy or Windows Update overriding settings.

**Solution**:
```powershell
# Check for Group Policy conflicts (domain environments)
gpresult /h gpresult.html
# Review the HTML file for conflicting policies

# Disable certain Windows Update features
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -Value 0
```

---

## Performance Issues

### Issue: Performance didn't improve after script

**Cause**: Restart required or background processes.

**Solution**:
1. **Restart computer** (required for many changes)
2. Check Task Manager for high CPU/memory processes
3. Verify settings were applied:
   ```powershell
   # Check visual effects setting
   Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
   
   # Check power plan
   powercfg /getactivescheme
   ```

### Issue: Computer feels slower after script

**Cause**: Some optimizations may not suit your workflow.

**Solution**:
```powershell
# Re-enable visual effects
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 0

# Switch back to Balanced power plan
powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e

# Re-enable Windows Search
Set-Service -Name "WSearch" -StartupType Automatic
Start-Service -Name "WSearch"

# Restart Explorer
taskkill /f /im explorer.exe & start explorer
```

---

## Rollback & Recovery

### Issue: Need to undo all changes

**Solution**: There's no automated rollback, but you can manually revert:

**System Restore** (if enabled before running script):
```powershell
# Check for restore points
Get-ComputerRestorePoint

# Restore to previous point
# Use System Properties > System Protection > System Restore
```

**Manual Reversion** of key settings:

```powershell
# Re-enable visual effects
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 0 -Type DWord

# Re-enable animations
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value 1 -Type String

# Re-enable transparency
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 1 -Type DWord

# Switch to Balanced power plan
powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e

# Re-enable hibernation
powercfg -h on

# Re-enable Windows Script Host
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Script Host\Settings" -Name "Enabled" -Value 1 -Type DWord

# Re-enable SysMain
Set-Service -Name "SysMain" -StartupType Automatic
Start-Service -Name "SysMain"

# Re-enable telemetry (if required by organization)
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 3 -Type DWord

# Restart Explorer
taskkill /f /im explorer.exe & start explorer

# Restart computer for all changes to take effect
Restart-Computer
```

### Issue: Need to uninstall all apps

**Solution**:
```powershell
# List all installed apps
winget list

# Uninstall specific app
winget uninstall --id PackageId

# Or use batch script
$appsToRemove = @("Git.Git", "Microsoft.VisualStudioCode", "OpenJS.NodeJS.LTS")
foreach ($app in $appsToRemove) {
    winget uninstall --id $app --silent
}
```

---

## Advanced Troubleshooting

### Detailed Logging

**Enable PowerShell transcript**:
```powershell
Start-Transcript -Path "C:\Logs\setup-transcript.txt"
.\Setup-DevMachine.ps1
Stop-Transcript
```

### Check Applied Settings

```powershell
# Export current registry settings
reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "C:\Logs\explorer-settings.reg"
reg export "HKCU\Control Panel\Desktop" "C:\Logs\desktop-settings.reg"

# Check service status
Get-Service | Where-Object {$_.Name -in @("WSearch", "SysMain", "DiagTrack", "dmwappushservice")} | Select-Object Name, Status, StartType
```

### Network Diagnostics

```powershell
# Test internet connectivity
Test-NetConnection -ComputerName www.microsoft.com -Port 443

# Check DNS
Resolve-DnsName github.com

# Test winget repository access
Test-NetConnection -ComputerName cdn.winget.microsoft.com -Port 443
```

### Windows Update Issues

```powershell
# If script conflicts with Windows Update
# Stop Windows Update temporarily
Stop-Service -Name "wuauserv" -Force

# Run script
.\Setup-DevMachine.ps1

# Restart Windows Update
Start-Service -Name "wuauserv"
```

### Event Viewer

Check Windows Event Viewer for detailed errors:
1. Open Event Viewer (`eventvwr.msc`)
2. Navigate to: Windows Logs > Application
3. Filter for PowerShell events
4. Look for errors around the time script was run

### Antivirus/Security Software

If antivirus is blocking:
```powershell
# Temporarily disable Windows Defender Real-Time Protection
Set-MpPreference -DisableRealtimeMonitoring $true

# Run script
.\Setup-DevMachine.ps1

# Re-enable
Set-MpPreference -DisableRealtimeMonitoring $false
```

---

## Getting Help

If issues persist:

1. **Review the log file**: `$env:USERPROFILE\Desktop\Lou32Deploy-Log.txt`
2. **Run with specific sections**: Use skip parameters to isolate issues
3. **Test in VM first**: Before running on production machine
4. **Check compatibility**: Ensure Windows 10 (1809+) or Windows 11
5. **Update Windows**: Ensure you're on the latest version
6. **Review documentation**: Check README.md and QUICKSTART.md

### Diagnostic Information to Collect

When reporting issues, provide:

```powershell
# System information
Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, OsBuildNumber, OsArchitecture

# PowerShell version
$PSVersionTable

# Execution policy
Get-ExecutionPolicy -List

# Log file content
Get-Content "$env:USERPROFILE\Desktop\Lou32Deploy-Log.txt" -Tail 50

# Installed apps
winget list

# Service status
Get-Service | Where-Object {$_.Name -match "winget|appinstaller"} | Format-List
```

---

## Prevention Tips

✅ **Before running the script:**
- Create a system restore point
- Backup important data
- Test in a VM first
- Review the script content
- Check Windows version compatibility
- Ensure stable internet connection
- Close all running applications

✅ **During execution:**
- Don't interrupt the script
- Monitor the console output
- Keep the log file open in another window
- Don't put computer to sleep

✅ **After execution:**
- Review the log file thoroughly
- Restart the computer
- Test critical applications
- Verify settings applied correctly

---

**Last Updated**: 2024-10-03  
**Script Version**: 1.0.0
