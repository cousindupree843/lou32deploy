# Lou32 Deployment Protocol - Quick Reference Guide

## Quick Start (3 Steps)

1. **Open PowerShell as Administrator**
   - Press `Win + X`
   - Click "Windows PowerShell (Admin)" or "Terminal (Admin)"

2. **Navigate to Script Location**
   ```powershell
   cd C:\Path\To\Script
   ```

3. **Run the Script**
   ```powershell
   .\Setup-DevMachine.ps1
   ```

## Common Commands

### Run Full Setup
```powershell
.\Setup-DevMachine.ps1
```

### Run Without Application Installation
```powershell
.\Setup-DevMachine.ps1 -SkipAppInstall
```

### Run Only Security Configuration
```powershell
.\Setup-DevMachine.ps1 -SkipAppInstall -SkipPerformanceTweaks -SkipUITweaks -SkipWingetInstall
```

### Run Only Performance Tweaks
```powershell
.\Setup-DevMachine.ps1 -SkipSecurityBaseline -SkipAppInstall -SkipUITweaks -SkipWingetInstall
```

## Execution Policy Issues

If you get an error about execution policy:

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
.\Setup-DevMachine.ps1
```

## What to Expect

### Total Time
- **Without Apps**: ~2-5 minutes
- **With Apps**: ~15-30 minutes (depending on internet speed)

### Output
- Colored console output (Cyan = Info, Yellow = Warning, Red = Error, Green = Success)
- Log file on Desktop: `Lou32Deploy-Log.txt`

### After Completion
- Review the log file for any errors
- Restart is **strongly recommended**
- Some changes require logout/login to take effect

## Verification

### Check Winget Installation
```powershell
winget --version
```

### Check Installed Applications
```powershell
winget list
```

### Check Applied Registry Settings
```powershell
# File extensions shown
Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt"

# Visual effects disabled
Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting"
```

## Rollback Individual Changes

### Re-enable Visual Effects
```powershell
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 0 -Type DWord
```

### Re-enable Windows Script Host
```powershell
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Script Host\Settings" -Name "Enabled" -Value 1 -Type DWord
```

### Re-enable Transparency
```powershell
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 1 -Type DWord
```

### Switch to Balanced Power Plan
```powershell
powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e
```

### Re-enable Hibernation
```powershell
powercfg -h on
```

## Troubleshooting

### Problem: Script Doesn't Start
**Solution**: Run as Administrator

### Problem: Winget Installation Fails
**Solutions**:
1. Check internet connection
2. Update Windows to latest version
3. Install Microsoft Store and update it
4. Try manual winget install from GitHub

### Problem: Some Apps Failed to Install
**Solutions**:
1. Check log file for specific errors
2. Run individual install: `winget install --id <PackageId>`
3. Check if app requires manual license acceptance
4. Verify internet connection

### Problem: Changes Not Visible
**Solutions**:
1. Restart Windows Explorer: `taskkill /f /im explorer.exe & start explorer`
2. Log out and back in
3. Restart the computer

## Customization Quick Tips

### Add Custom Application
Edit `Setup-DevMachine.ps1`, find the `$applications` array, add:
```powershell
@{Name="App Name"; Id="Winget.PackageId"}
```

### Find Package ID
```powershell
winget search "application name"
```

### Disable Specific Registry Tweak
Comment out the line with `#` in the script

## Safety Tips

✅ **DO:**
- Test in a VM first
- Read the script before running
- Review the log file after execution
- Keep a system backup
- Run on a fresh Windows install for best results

❌ **DON'T:**
- Run without Administrator privileges
- Skip the restart prompt
- Interrupt the script during execution
- Run on production systems without testing

## Performance Impact

### Expected Improvements:
- ✅ Faster boot time (no startup delay)
- ✅ More responsive UI (no animations)
- ✅ Lower memory usage (fewer background services)
- ✅ More disk space (hibernation disabled)
- ✅ Better battery life on laptops (optimized services)

### Potential Trade-offs:
- ⚠️ No transparency effects
- ⚠️ No window animations
- ⚠️ Reduced search indexing
- ⚠️ Cortana disabled

## Support & Resources

### Check Script Status
```powershell
Get-Content "$env:USERPROFILE\Desktop\Lou32Deploy-Log.txt" -Tail 50
```

### View All Winget Apps
```powershell
winget list
```

### Export Installed Apps List
```powershell
winget export -o installed-apps.json
```

### Update All Apps
```powershell
winget upgrade --all
```

## After Deployment Checklist

- [ ] Review log file for errors
- [ ] Verify all desired applications installed
- [ ] Test critical applications
- [ ] Configure application settings
- [ ] Set up development environment variables
- [ ] Configure Git (user.name, user.email)
- [ ] Set up SSH keys
- [ ] Configure IDE/editor preferences
- [ ] Install additional extensions/plugins
- [ ] Restart computer
- [ ] Verify all changes applied correctly

## Next Steps

1. **Configure Git**
   ```powershell
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

2. **Set Up SSH**
   ```powershell
   ssh-keygen -t ed25519 -C "your.email@example.com"
   ```

3. **Update All Packages**
   ```powershell
   winget upgrade --all
   ```

4. **Install VS Code Extensions** (if needed)
   ```powershell
   code --install-extension ms-python.python
   code --install-extension ms-vscode.powershell
   ```

## Version Info

- **Script Version**: 1.0.0
- **Last Updated**: 2024
- **Compatibility**: Windows 10 (1809+), Windows 11

---

For detailed documentation, see [README.md](README.md)
