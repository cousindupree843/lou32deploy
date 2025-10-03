<#
.SYNOPSIS
    Lou32 Deployment Protocol - Enterprise Windows Development Machine Configuration Script

.DESCRIPTION
    This script configures a fresh Windows 10/11 installation for enterprise development use.
    It sets security baselines, installs winget package manager, configures applications,
    disables visual effects for performance, and tweaks UI defaults.

.NOTES
    Author: Lou32 Deployment Protocol
    Version: 1.0.0
    Requires: PowerShell 5.1 or higher, Administrator privileges
    Compatible: Windows 10 (1809+), Windows 11

.EXAMPLE
    .\Setup-DevMachine.ps1
    Runs the full configuration with default settings

.EXAMPLE
    .\Setup-DevMachine.ps1 -SkipAppInstall
    Runs configuration but skips application installation
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [switch]$SkipSecurityBaseline,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipWingetInstall,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipAppInstall,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipPerformanceTweaks,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipUITweaks,
    
    [Parameter(Mandatory=$false)]
    [string]$LogPath = "$env:USERPROFILE\Desktop\Lou32Deploy-Log.txt"
)

#Requires -RunAsAdministrator

# Script configuration
$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"
$script:LogFile = $LogPath

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================

function Write-Log {
    <#
    .SYNOPSIS
        Writes timestamped log messages to console and file
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Color coding for console output
    switch ($Level) {
        "INFO"    { Write-Host $logMessage -ForegroundColor Cyan }
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        "ERROR"   { Write-Host $logMessage -ForegroundColor Red }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
    }
    
    # Write to log file
    Add-Content -Path $script:LogFile -Value $logMessage -ErrorAction SilentlyContinue
}

function Start-Section {
    param([string]$Title)
    $separator = "=" * 80
    Write-Log -Message $separator -Level "INFO"
    Write-Log -Message $Title -Level "INFO"
    Write-Log -Message $separator -Level "INFO"
}

# ============================================================================
# PREREQUISITE CHECKS
# ============================================================================

function Test-Prerequisites {
    <#
    .SYNOPSIS
        Validates system requirements before running configuration
    #>
    Start-Section "PREREQUISITE CHECKS"
    
    # Check Windows version
    $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
    $buildNumber = [int]$osInfo.BuildNumber
    
    Write-Log "OS: $($osInfo.Caption) (Build $buildNumber)"
    
    if ($buildNumber -lt 17763) {
        Write-Log "Windows 10 version 1809 or higher is required. Current build: $buildNumber" -Level "ERROR"
        return $false
    }
    
    # Check PowerShell version
    $psVersion = $PSVersionTable.PSVersion
    Write-Log "PowerShell Version: $psVersion"
    
    if ($psVersion.Major -lt 5) {
        Write-Log "PowerShell 5.1 or higher is required" -Level "ERROR"
        return $false
    }
    
    # Check admin privileges
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $isAdmin) {
        Write-Log "This script must be run as Administrator" -Level "ERROR"
        return $false
    }
    
    Write-Log "All prerequisite checks passed" -Level "SUCCESS"
    return $true
}

# ============================================================================
# SECURITY BASELINE CONFIGURATION
# ============================================================================

function Set-SecurityBaseline {
    <#
    .SYNOPSIS
        Configures enterprise security baselines
    #>
    Start-Section "CONFIGURING SECURITY BASELINE"
    
    try {
        # Disable SMBv1 (security vulnerability)
        Write-Log "Disabling SMBv1 protocol..."
        Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart -ErrorAction SilentlyContinue
        
        # Enable Windows Defender Real-Time Protection
        Write-Log "Enabling Windows Defender Real-Time Protection..."
        Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction SilentlyContinue
        
        # Configure Windows Firewall
        Write-Log "Ensuring Windows Firewall is enabled..."
        Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True -ErrorAction SilentlyContinue
        
        # Disable AutoRun/AutoPlay
        Write-Log "Disabling AutoRun for all drives..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -Value 255 -Type DWord -Force -ErrorAction SilentlyContinue
        
        # Enable UAC
        Write-Log "Configuring User Account Control (UAC)..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 2 -Type DWord -Force -ErrorAction SilentlyContinue
        
        # Disable Remote Desktop (enable if needed)
        Write-Log "Configuring Remote Desktop settings..."
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        
        # Enable Network Level Authentication for RDP
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        
        # Configure screen saver lock
        Write-Log "Configuring screen saver security..."
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "ScreenSaveActive" -Value 1 -Type String -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "ScreenSaverIsSecure" -Value 1 -Type String -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "ScreenSaveTimeOut" -Value 900 -Type String -Force -ErrorAction SilentlyContinue
        
        # Disable Windows Script Host (WSH) for enhanced security
        Write-Log "Configuring Windows Script Host restrictions..."
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows Script Host\Settings" -Force -ErrorAction SilentlyContinue | Out-Null
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Script Host\Settings" -Name "Enabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        
        # Configure password policy via secpol
        Write-Log "Password policy should be configured via Group Policy or secpol.msc"
        
        Write-Log "Security baseline configuration completed" -Level "SUCCESS"
    }
    catch {
        Write-Log "Error configuring security baseline: $($_.Exception.Message)" -Level "ERROR"
    }
}

# ============================================================================
# WINGET INSTALLATION
# ============================================================================

function Install-Winget {
    <#
    .SYNOPSIS
        Installs Windows Package Manager (winget) if not already present
    #>
    Start-Section "INSTALLING WINGET PACKAGE MANAGER"
    
    try {
        # Check if winget is already installed
        $wingetPath = (Get-Command winget -ErrorAction SilentlyContinue).Source
        
        if ($wingetPath) {
            Write-Log "Winget is already installed at: $wingetPath" -Level "SUCCESS"
            $version = winget --version
            Write-Log "Winget version: $version"
            return $true
        }
        
        Write-Log "Winget not found. Installing..."
        
        # Install App Installer (includes winget) from Microsoft Store
        Write-Log "Downloading latest App Installer package..."
        
        # Download and install VCLibs dependency
        $vcLibsUrl = "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx"
        $vcLibsPath = "$env:TEMP\Microsoft.VCLibs.x64.14.00.Desktop.appx"
        
        Write-Log "Downloading VCLibs dependency..."
        Invoke-WebRequest -Uri $vcLibsUrl -OutFile $vcLibsPath -UseBasicParsing
        Add-AppxPackage -Path $vcLibsPath -ErrorAction SilentlyContinue
        
        # Download and install UI.Xaml dependency
        $uiXamlUrl = "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx"
        $uiXamlPath = "$env:TEMP\Microsoft.UI.Xaml.2.8.x64.appx"
        
        Write-Log "Downloading UI.Xaml dependency..."
        Invoke-WebRequest -Uri $uiXamlUrl -OutFile $uiXamlPath -UseBasicParsing
        Add-AppxPackage -Path $uiXamlPath -ErrorAction SilentlyContinue
        
        # Download and install winget (App Installer)
        $wingetUrl = "https://aka.ms/getwinget"
        $wingetPath = "$env:TEMP\Microsoft.DesktopAppInstaller.msixbundle"
        
        Write-Log "Downloading winget installer..."
        Invoke-WebRequest -Uri $wingetUrl -OutFile $wingetPath -UseBasicParsing
        Add-AppxPackage -Path $wingetPath
        
        # Wait for installation and verify
        Start-Sleep -Seconds 5
        $wingetCheck = Get-Command winget -ErrorAction SilentlyContinue
        
        if ($wingetCheck) {
            Write-Log "Winget installed successfully" -Level "SUCCESS"
            $version = winget --version
            Write-Log "Winget version: $version"
            return $true
        }
        else {
            Write-Log "Winget installation verification failed" -Level "ERROR"
            return $false
        }
    }
    catch {
        Write-Log "Error installing winget: $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
}

# ============================================================================
# APPLICATION INSTALLATION
# ============================================================================

function Install-Applications {
    <#
    .SYNOPSIS
        Installs development applications using winget
    #>
    Start-Section "INSTALLING APPLICATIONS VIA WINGET"
    
    # Define application list for development machine
    $applications = @(
        @{Name="Git"; Id="Git.Git"},
        @{Name="Visual Studio Code"; Id="Microsoft.VisualStudioCode"},
        @{Name="Windows Terminal"; Id="Microsoft.WindowsTerminal"},
        @{Name="PowerShell 7"; Id="Microsoft.PowerShell"},
        @{Name="Node.js LTS"; Id="OpenJS.NodeJS.LTS"},
        @{Name="Python 3"; Id="Python.Python.3.12"},
        @{Name="7-Zip"; Id="7zip.7zip"},
        @{Name="Notepad++"; Id="Notepad++.Notepad++"},
        @{Name="Google Chrome"; Id="Google.Chrome"},
        @{Name="Mozilla Firefox"; Id="Mozilla.Firefox"},
        @{Name="Docker Desktop"; Id="Docker.DockerDesktop"},
        @{Name="Postman"; Id="Postman.Postman"},
        @{Name="Slack"; Id="SlackTechnologies.Slack"},
        @{Name="Microsoft Teams"; Id="Microsoft.Teams"},
        @{Name=".NET SDK"; Id="Microsoft.DotNet.SDK.8"}
    )
    
    foreach ($app in $applications) {
        try {
            Write-Log "Installing $($app.Name)..."
            
            # Accept package agreements and install silently
            $installResult = winget install --id $($app.Id) --silent --accept-package-agreements --accept-source-agreements 2>&1
            
            if ($LASTEXITCODE -eq 0 -or $installResult -match "successfully installed" -or $installResult -match "already installed") {
                Write-Log "$($app.Name) installed successfully" -Level "SUCCESS"
            }
            else {
                Write-Log "$($app.Name) installation completed with warnings" -Level "WARNING"
            }
        }
        catch {
            Write-Log "Error installing $($app.Name): $($_.Exception.Message)" -Level "ERROR"
        }
    }
    
    Write-Log "Application installation completed" -Level "SUCCESS"
}

# ============================================================================
# PERFORMANCE OPTIMIZATIONS
# ============================================================================

function Disable-VisualEffects {
    <#
    .SYNOPSIS
        Disables Windows visual effects for maximum performance
    #>
    Start-Section "DISABLING VISUAL EFFECTS FOR PERFORMANCE"
    
    try {
        # Set for best performance
        Write-Log "Configuring visual effects for best performance..."
        
        # Disable animations
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value 0 -Type String -Force -ErrorAction SilentlyContinue
        
        # Disable visual effects via SystemParametersInfo
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2 -Type DWord -Force -ErrorAction SilentlyContinue
        
        # Disable taskbar animations
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        
        # Disable window animations
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -Type Binary -Force -ErrorAction SilentlyContinue
        
        # Disable smooth scrolling
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "SmoothScroll" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        
        # Disable window shadows
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewShadow" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        
        # Disable transparency
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        
        # Additional performance settings
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewAlphaSelect" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "EnableAeroPeek" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "AlwaysHibernateThumbnails" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        
        # Disable thumbnail previews
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "IconsOnly" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        
        # Disable Aero Shake
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisallowShaking" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        
        Write-Log "Visual effects disabled for maximum performance" -Level "SUCCESS"
    }
    catch {
        Write-Log "Error disabling visual effects: $($_.Exception.Message)" -Level "ERROR"
    }
}

function Optimize-SystemPerformance {
    <#
    .SYNOPSIS
        Additional system performance optimizations
    #>
    Start-Section "OPTIMIZING SYSTEM PERFORMANCE"
    
    try {
        # Disable Windows Search indexing on system drive (optional)
        Write-Log "Configuring Windows Search..."
        Set-Service -Name "WSearch" -StartupType Manual -ErrorAction SilentlyContinue
        
        # Disable Superfetch/SysMain (good for SSDs)
        Write-Log "Configuring SysMain (Superfetch)..."
        Set-Service -Name "SysMain" -StartupType Disabled -ErrorAction SilentlyContinue
        Stop-Service -Name "SysMain" -Force -ErrorAction SilentlyContinue
        
        # Disable Windows Tips
        Write-Log "Disabling Windows Tips..."
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        
        # Disable Cortana
        Write-Log "Disabling Cortana..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        
        # Set power plan to High Performance
        Write-Log "Setting power plan to High Performance..."
        $highPerfGuid = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
        powercfg -setactive $highPerfGuid 2>&1 | Out-Null
        
        # Disable hibernation to save disk space
        Write-Log "Disabling hibernation..."
        powercfg -h off 2>&1 | Out-Null
        
        # Disable startup delay
        Write-Log "Disabling startup delay..."
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" -Name "StartupDelayInMSec" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        
        Write-Log "System performance optimization completed" -Level "SUCCESS"
    }
    catch {
        Write-Log "Error optimizing system performance: $($_.Exception.Message)" -Level "ERROR"
    }
}

# ============================================================================
# UI TWEAKS
# ============================================================================

function Set-UIDefaults {
    <#
    .SYNOPSIS
        Configures UI defaults and preferences
    #>
    Start-Section "CONFIGURING UI DEFAULTS"
    
    try {
        # Show file extensions
        Write-Log "Showing file extensions in Explorer..."
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        
        # Show hidden files
        Write-Log "Showing hidden files in Explorer..."
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        
        # Show protected operating system files (optional, be careful)
        # Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSuperHidden" -Value 1 -Type DWord -Force
        
        # Show full path in title bar
        Write-Log "Showing full path in Explorer title bar..."
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" -Name "FullPath" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        
        # Disable quick access
        Write-Log "Configuring Quick Access..."
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowRecent" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowFrequent" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        
        # Open File Explorer to This PC instead of Quick Access
        Write-Log "Setting File Explorer to open to This PC..."
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        
        # Disable Bing search in Start Menu
        Write-Log "Disabling Bing search in Start Menu..."
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        
        # Disable web search in Start Menu
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        
        # Enable Dark Mode
        Write-Log "Enabling Dark Mode..."
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        
        # Taskbar settings - small icons
        Write-Log "Configuring taskbar settings..."
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarSmallIcons" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        
        # Hide Task View button
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        
        # Hide People button
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        
        # Disable News and Interests on taskbar
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds" -Name "ShellFeedsTaskbarViewMode" -Value 2 -Type DWord -Force -ErrorAction SilentlyContinue
        
        # Disable suggested content in Settings
        Write-Log "Disabling suggested content..."
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353694Enabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353696Enabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        
        Write-Log "UI defaults configuration completed" -Level "SUCCESS"
    }
    catch {
        Write-Log "Error configuring UI defaults: $($_.Exception.Message)" -Level "ERROR"
    }
}

function Disable-TelemetryAndPrivacy {
    <#
    .SYNOPSIS
        Disables telemetry and improves privacy settings
    #>
    Start-Section "CONFIGURING PRIVACY AND TELEMETRY SETTINGS"
    
    try {
        # Disable telemetry
        Write-Log "Disabling telemetry..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        
        # Disable DiagTrack service
        Write-Log "Disabling DiagTrack service..."
        Set-Service -Name "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue
        Stop-Service -Name "DiagTrack" -Force -ErrorAction SilentlyContinue
        
        # Disable dmwappushservice
        Set-Service -Name "dmwappushservice" -StartupType Disabled -ErrorAction SilentlyContinue
        Stop-Service -Name "dmwappushservice" -Force -ErrorAction SilentlyContinue
        
        # Disable Activity History
        Write-Log "Disabling Activity History..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        
        # Disable location tracking
        Write-Log "Disabling location tracking..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableLocation" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        
        # Disable advertising ID
        Write-Log "Disabling advertising ID..."
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        
        Write-Log "Privacy and telemetry configuration completed" -Level "SUCCESS"
    }
    catch {
        Write-Log "Error configuring privacy settings: $($_.Exception.Message)" -Level "ERROR"
    }
}

# ============================================================================
# CLEANUP AND FINALIZATION
# ============================================================================

function Invoke-Cleanup {
    <#
    .SYNOPSIS
        Performs cleanup operations
    #>
    Start-Section "PERFORMING CLEANUP"
    
    try {
        Write-Log "Cleaning up temporary files..."
        
        # Clean temp files
        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
        
        # Clean Windows Update cache
        Write-Log "Cleaning Windows Update cache..."
        Stop-Service -Name "wuauserv" -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
        Start-Service -Name "wuauserv" -ErrorAction SilentlyContinue
        
        # Restart Explorer to apply UI changes
        Write-Log "Restarting Windows Explorer to apply changes..."
        Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        
        Write-Log "Cleanup completed" -Level "SUCCESS"
    }
    catch {
        Write-Log "Error during cleanup: $($_.Exception.Message)" -Level "ERROR"
    }
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

function Main {
    # Initialize log file
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "Lou32 Deployment Protocol - Execution Log" | Out-File -FilePath $script:LogFile -Force
    "Started: $timestamp" | Out-File -FilePath $script:LogFile -Append
    "=" * 80 | Out-File -FilePath $script:LogFile -Append
    
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                    LOU32 DEPLOYMENT PROTOCOL v1.0.0                           ║" -ForegroundColor Cyan
    Write-Host "║           Enterprise Windows Development Machine Configuration                ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    # Run prerequisite checks
    if (-not (Test-Prerequisites)) {
        Write-Log "Prerequisite checks failed. Exiting..." -Level "ERROR"
        return
    }
    
    # Execute configuration steps
    if (-not $SkipSecurityBaseline) {
        Set-SecurityBaseline
    } else {
        Write-Log "Skipping security baseline configuration (parameter specified)" -Level "WARNING"
    }
    
    if (-not $SkipWingetInstall) {
        Install-Winget
    } else {
        Write-Log "Skipping winget installation (parameter specified)" -Level "WARNING"
    }
    
    if (-not $SkipAppInstall) {
        Install-Applications
    } else {
        Write-Log "Skipping application installation (parameter specified)" -Level "WARNING"
    }
    
    if (-not $SkipPerformanceTweaks) {
        Disable-VisualEffects
        Optimize-SystemPerformance
    } else {
        Write-Log "Skipping performance tweaks (parameter specified)" -Level "WARNING"
    }
    
    if (-not $SkipUITweaks) {
        Set-UIDefaults
        Disable-TelemetryAndPrivacy
    } else {
        Write-Log "Skipping UI tweaks (parameter specified)" -Level "WARNING"
    }
    
    # Cleanup
    Invoke-Cleanup
    
    # Final summary
    Start-Section "DEPLOYMENT COMPLETED"
    Write-Log "Lou32 Deployment Protocol execution completed successfully!" -Level "SUCCESS"
    Write-Log "Log file saved to: $script:LogFile" -Level "INFO"
    Write-Log "A system restart is recommended to apply all changes" -Level "WARNING"
    
    # Prompt for restart
    Write-Host ""
    $restart = Read-Host "Would you like to restart the computer now? (Y/N)"
    if ($restart -eq "Y" -or $restart -eq "y") {
        Write-Log "Restarting computer in 10 seconds..." -Level "WARNING"
        Start-Sleep -Seconds 10
        Restart-Computer -Force
    }
    else {
        Write-Log "Please restart the computer manually to apply all changes" -Level "WARNING"
    }
}

# Run main function
Main
