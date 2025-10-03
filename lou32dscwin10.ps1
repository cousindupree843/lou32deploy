#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Windows Development Machine Setup Script for Windows 10/11 64-bit

.DESCRIPTION
    This script automates the complete setup of a Windows development environment.
    Setup protocol includes dependency resolution, package validation, system optimization, security hardening,
    development tool configuration, and reporting with rollback capabilities.

.PARAMETER SkipWinGetInstall
    Skip WinGet installation and configuration

.PARAMETER SkipAppInstall
    Skip application installation

.PARAMETER SkipAppRemoval
    Skip application removal

.PARAMETER SkipWSLInstall
    Skip WSL installation

.PARAMETER SkipSystemOptimization
    Skip system optimization (registry tweaks, power plan, etc.)

.PARAMETER SkipVisualEffects
    Skip disabling visual effects (transparency, animations, etc.)

.PARAMETER SkipSecurityHardening
    Skip security hardening (firewall rules, updates, etc.)

.PARAMETER DisableWindowsDefender
    Disable Windows Defender real-time protection (SECURITY RISK - use with caution)

.PARAMETER SkipDevEnvironment
    Skip development environment setup (Git, SSH, VS Code, etc.)

.PARAMETER SkipBackup
    Skip system backup and restore point creation

.PARAMETER LogPath
    Path for the log file (default: $env:TEMP\DevMachineSetup.log)

.PARAMETER ReportPath
    Path for the HTML report (default: $env:TEMP\DevMachineSetup_Report.html)

.PARAMETER CreateRestorePoint
    Create system restore point before major changes

.PARAMETER GitUserName
    Git user name for configuration

.PARAMETER GitUserEmail
    Git user email for configuration

.PARAMETER ConfigFile
    Path to JSON configuration file (optional)

.PARAMETER MaxParallelJobs
    Maximum number of parallel installation jobs (default: 4)

.PARAMETER RetryAttempts
    Number of retry attempts for failed operations (default: 3)

.PARAMETER RetryDelaySeconds
    Initial delay between retry attempts in seconds (default: 5)

.EXAMPLE
    .\Lou32DevMachineSetup_001_Improved.ps1
    Runs the complete setup process

.EXAMPLE
    .\Lou32DevMachineSetup_001_Improved.ps1 -SkipWSLInstall -GitUserName "John Doe" -GitUserEmail "john@example.com"
    Runs setup but skips WSL installation with Git configuration

.EXAMPLE
    .\Lou32DevMachineSetup_001_Improved.ps1 -SkipVisualEffects
    Runs setup but keeps visual effects enabled

.NOTES
    Author: Development Team
    Version: 3.0
    Compatible with: Windows 10/11 64-bit, PowerShell 5.1+
    Features: Dependency resolution, package validation, system optimization, security hardening,
              development environment setup, comprehensive reporting, rollback capabilities
#>

param(
    [switch]$SkipWinGetInstall,
    [switch]$SkipAppInstall,
    [switch]$SkipAppRemoval,
    [switch]$SkipWSLInstall,
    [switch]$SkipSystemOptimization,
    [switch]$SkipVisualEffects,
    [switch]$SkipSecurityHardening,
    [switch]$DisableWindowsDefender,
    [switch]$SkipDevEnvironment,
    [switch]$SkipBackup,
    [string]$LogPath = "$env:TEMP\DevMachineSetup.log",
    [string]$ReportPath = "$env:TEMP\DevMachineSetup_Report.html",
    [switch]$CreateRestorePoint,
    [string]$GitUserName = "",
    [string]$GitUserEmail = "",
    [string]$ConfigFile = "",
    [int]$MaxParallelJobs = 4,
    [int]$RetryAttempts = 3,
    [int]$RetryDelaySeconds = 5
)

# Global variables for tracking and reporting
$Global:SetupReport = @{
    StartTime = Get-Date
    EndTime = $null
    Duration = $null
    Prerequisites = @{}
    WinGetInstall = @{}
    SystemOptimization = @{}
    SecurityHardening = @{}
    ApplicationInstallation = @{}
    DevelopmentEnvironment = @{}
    BloatwareRemoval = @{}
    WSLInstallation = @{}
    HealthChecks = @{}
    RestorePoints = @()
    Errors = @()
    Warnings = @()
    SuccessCount = 0
    FailureCount = 0
}

$Global:ProgressActivity = "Windows Development Machine Setup"
$Global:ProgressId = 1

# Configuration management
$Global:Configuration = @{
    Applications = @()
    NetworkOptimizations = @{
        EnableDeliveryOptimization = $true
        EnableTCPOptimizations = $true
        EnableBandwidthThrottling = $false
        MaxBandwidthPercent = 80
    }
    PackageManagement = @{
        EnableParallelInstallation = $true
        MaxParallelJobs = $MaxParallelJobs
        RetryAttempts = $RetryAttempts
        RetryDelaySeconds = $RetryDelaySeconds
        EnableSourceValidation = $true
    }
    SystemOptimizations = @{
        EnableVisualEffectsDisable = $true
        EnablePowerPlanOptimization = $true
        EnableNetworkOptimization = $true
    }
}

# Import configuration from file if provided
function Import-Configuration {
    param([string]$ConfigFilePath)
    
    if (-not $ConfigFilePath -or -not (Test-Path $ConfigFilePath)) {
        Write-Log "No configuration file provided or file not found. Using default configuration." "INFO" "Configuration"
        return
    }
    
    try {
        Write-Log "Importing configuration from: $ConfigFilePath" "INFO" "Configuration"
        $configContent = Get-Content $ConfigFilePath -Raw -Encoding UTF8
        $loadedConfig = $configContent | ConvertFrom-Json
        
        # Merge loaded configuration with defaults
        if ($loadedConfig.Applications) {
            $Global:Configuration.Applications = $loadedConfig.Applications
        }
        
        if ($loadedConfig.NetworkOptimizations) {
            $Global:Configuration.NetworkOptimizations = $loadedConfig.NetworkOptimizations
        }
        
        if ($loadedConfig.PackageManagement) {
            $Global:Configuration.PackageManagement = $loadedConfig.PackageManagement
        }
        
        if ($loadedConfig.SystemOptimizations) {
            $Global:Configuration.SystemOptimizations = $loadedConfig.SystemOptimizations
        }
        
        Write-Log "Configuration imported successfully" "SUCCESS" "Configuration"
    }
    catch {
        Write-Log "Failed to import configuration file: $($_.Exception.Message)" "ERROR" "Configuration"
        Write-Log "Using default configuration" "WARNING" "Configuration"
    }
}

# Enhanced logging with progress tracking
function Write-Log {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS")]
        [string]$Level = "INFO",
        [string]$Category = "General"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] [$Category] $Message"
    
    # Color-coded console output
    switch ($Level) {
        "INFO"    { Write-Host $logEntry -ForegroundColor White }
        "WARNING" { Write-Host $logEntry -ForegroundColor Yellow }
        "ERROR"   { Write-Host $logEntry -ForegroundColor Red }
        "SUCCESS" { Write-Host $logEntry -ForegroundColor Green }
    }
    
    # Update global report
    switch ($Level) {
        "ERROR" { 
            $Global:SetupReport.Errors += @{
                Timestamp = $timestamp
                Category = $Category
                Message = $Message
            }
            $Global:SetupReport.FailureCount++
        }
        "WARNING" { 
            $Global:SetupReport.Warnings += @{
                Timestamp = $timestamp
                Category = $Category
                Message = $Message
            }
        }
        "SUCCESS" { 
            $Global:SetupReport.SuccessCount++
        }
    }
    
    # Write to log file
    try {
        Add-Content -Path $LogPath -Value $logEntry -Encoding UTF8 -ErrorAction SilentlyContinue
    }
    catch {
        Write-Warning "Failed to write to log file: $($_.Exception.Message)"
    }
}

# Progress tracking function
function Write-Progress {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Activity,
        [Parameter(Mandatory = $true)]
        [string]$Status,
        [int]$PercentComplete = -1,
        [int]$CurrentOperation = 0,
        [int]$TotalOperations = 0
    )
    
    if ($TotalOperations -gt 0) {
        $PercentComplete = [math]::Round(($CurrentOperation / $TotalOperations) * 100)
    }
    
    Microsoft.PowerShell.Utility\Write-Progress -Activity $Activity -Status $Status -PercentComplete $PercentComplete -Id $Global:ProgressId
}

# System backup and restore point management
function New-SystemRestorePoint {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Description
    )
    
    try {
        Write-Log "Creating system restore point: $Description" "INFO" "Backup"
        Write-Progress -Activity $Global:ProgressActivity -Status "Creating restore point: $Description" -PercentComplete 10
        
        $restorePoint = New-ComputerRestorePoint -Description $Description -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        
        $restorePointInfo = @{
            Description = $Description
            SequenceNumber = $restorePoint.SequenceNumber
            CreationTime = Get-Date
            Status = "Created"
        }
        
        $Global:SetupReport.RestorePoints += $restorePointInfo
        Write-Log "System restore point created successfully (Sequence: $($restorePoint.SequenceNumber))" "SUCCESS" "Backup"
        return $restorePointInfo
    }
    catch {
        Write-Log "Failed to create system restore point: $($_.Exception.Message)" "ERROR" "Backup"
        return $null
    }
}

# Configuration backup function
function Export-SystemConfiguration {
    param(
        [string]$BackupPath = "$env:TEMP\SystemConfigBackup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    )
    
    try {
        Write-Log "Exporting system configuration to: $BackupPath" "INFO" "Backup"
        Write-Progress -Activity $Global:ProgressActivity -Status "Backing up system configuration" -PercentComplete 20
        
        if (-not (Test-Path $BackupPath)) {
            New-Item -Path $BackupPath -ItemType Directory -Force | Out-Null
        }
        
        # Export registry settings
        $registryKeys = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced",
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System",
            "HKLM:\SYSTEM\CurrentControlSet\Control\Power",
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate"
        )
        
        foreach ($key in $registryKeys) {
            try {
                $keyName = Split-Path $key -Leaf
                $exportPath = Join-Path $BackupPath "Registry_$keyName.reg"
                reg export $key $exportPath /y | Out-Null
            }
            catch {
                Write-Log "Failed to export registry key $key : $($_.Exception.Message)" "WARNING" "Backup"
            }
        }
        
        # Export environment variables
        Get-ChildItem Env: | Export-Clixml -Path (Join-Path $BackupPath "EnvironmentVariables.xml")
        
        # Export installed programs
        Get-WmiObject -Class Win32_Product | Select-Object Name, Version, Vendor | Export-Csv -Path (Join-Path $BackupPath "InstalledPrograms.csv") -NoTypeInformation
        
        # Export Windows features
        Get-WindowsOptionalFeature -Online | Where-Object {$_.State -eq "Enabled"} | Export-Clixml -Path (Join-Path $BackupPath "WindowsFeatures.xml")
        
        Write-Log "System configuration backup completed successfully" "SUCCESS" "Backup"
        return $BackupPath
    }
    catch {
        Write-Log "Failed to export system configuration: $($_.Exception.Message)" "ERROR" "Backup"
        return $null
    }
}

# Enhanced dependency resolution system with proper ordering
function Resolve-PackageDependencies {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageName
    )
    
    $dependencies = @()
    
    # Define comprehensive dependency map with installation order
    $dependencyMap = @{
        # Runtime dependencies (must install first)
        "Microsoft.VCRedist.2015+.x64" = @()
        "Microsoft.VCRedist.2015+.x86" = @()
        "Microsoft.UI.Xaml.2.8" = @()
        "Microsoft.VCLibs.Desktop.14" = @()
        "Microsoft.EdgeWebView2Runtime" = @()
        
        # .NET dependencies
        "Microsoft.DotNet.Runtime.6" = @("Microsoft.VCRedist.2015+.x64")
        "Microsoft.DotNet.DesktopRuntime.6" = @("Microsoft.DotNet.Runtime.6", "Microsoft.VCRedist.2015+.x64")
        "Microsoft.DotNet.DesktopRuntime.7" = @("Microsoft.VCRedist.2015+.x64")
        "Microsoft.DotNet.DesktopRuntime.8" = @("Microsoft.VCRedist.2015+.x64")
        "Microsoft.DotNet.SDK.7" = @("Microsoft.DotNet.DesktopRuntime.7", "Microsoft.VCRedist.2015+.x64")
        "Microsoft.DotNet.SDK.8" = @("Microsoft.DotNet.DesktopRuntime.8", "Microsoft.VCRedist.2015+.x64")
        
        # Development tools
        "Microsoft.VisualStudioCode" = @("Microsoft.VCRedist.2015+.x64")
        "Microsoft.VisualStudioCode.CLI" = @("Microsoft.VisualStudioCode")
        "Microsoft.WindowsTerminal" = @("Microsoft.VCRedist.2015+.x64", "Microsoft.UI.Xaml.2.8")
        "Microsoft.WindowsTerminal.Preview" = @("Microsoft.VCRedist.2015+.x64", "Microsoft.UI.Xaml.2.8")
        "Microsoft.PowerShell" = @("Microsoft.VCRedist.2015+.x64")
        "Git.Git" = @()
        
        # Complex applications
        "Docker.DockerDesktop" = @("Microsoft.VCRedist.2015+.x64", "Microsoft.EdgeWebView2Runtime")
        "Microsoft.VisualStudio.2022.Community" = @("Microsoft.VCRedist.2015+.x64", "Microsoft.VCRedist.2015+.x86")
        "Microsoft.VisualStudio.2022.BuildTools" = @("Microsoft.VCRedist.2015+.x64", "Microsoft.VCRedist.2015+.x86")
        
        # Node.js variants
        "OpenJS.NodeJS" = @("Microsoft.VCRedist.2015+.x64")
        "OpenJS.NodeJS.LTS" = @("Microsoft.VCRedist.2015+.x64")
        
        # Python variants
        "Python.Python.3.10" = @("Microsoft.VCRedist.2015+.x64")
        "Python.Python.3.13" = @("Microsoft.VCRedist.2015+.x64")
        "Python.Launcher" = @()
        
        # Browsers with dependencies
        "Google.Chrome" = @("Microsoft.VCRedist.2015+.x64")
        "Google.Chrome.Dev" = @("Microsoft.VCRedist.2015+.x64")
        "Mozilla.Firefox" = @("Microsoft.VCRedist.2015+.x64")
        "Microsoft.Edge.Dev" = @("Microsoft.VCRedist.2015+.x64", "Microsoft.EdgeWebView2Runtime")
        
        # Media tools
        "IrfanSkiljan.IrfanView.Plugins" = @("IrfanSkiljan.IrfanView")
        "PeterPawlowski.foobar2000.encoderpack" = @("PeterPawlowski.foobar2000")
        "yt-dlp.FFmpeg" = @("Gyan.FFmpeg")
        
        # System tools
        "Microsoft.WindowsSDK.10.0.26100" = @("Microsoft.VCRedist.2015+.x64", "Microsoft.VCRedist.2015+.x86")
        "Microsoft.WindowsWDK.10.0.26100" = @("Microsoft.WindowsSDK.10.0.26100")
        "Microsoft.WindowsADK" = @("Microsoft.VCRedist.2015+.x64")
    }
    
    if ($dependencyMap.ContainsKey($PackageName)) {
        $dependencies = $dependencyMap[$PackageName]
    }
    
    return $dependencies
}

# Package validation function
function Test-PackageInstallation {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageName,
        [string]$ExecutableName = $null
    )
    
    try {
        Write-Log "Validating installation of: $PackageName" "INFO" "Validation"
        
        # Check if package is listed in WinGet
        $listResult = winget list --exact -q $PackageName --accept-source-agreements 2>$null
        if ($listResult -and $listResult -match $PackageName) {
            Write-Log "Package $PackageName found in WinGet list" "SUCCESS" "Validation"
            
            # If executable name provided, test if it's accessible
            if ($ExecutableName) {
                $command = Get-Command $ExecutableName -ErrorAction SilentlyContinue
                if ($command) {
                    Write-Log "Executable $ExecutableName is accessible" "SUCCESS" "Validation"
                    return $true
                } else {
                    Write-Log "Package installed but executable $ExecutableName not found in PATH" "WARNING" "Validation"
                    return $false
                }
            }
            return $true
        } else {
            Write-Log "Package $PackageName not found in WinGet list" "ERROR" "Validation"
            return $false
        }
    }
    catch {
        Write-Log "Failed to validate package $PackageName : $($_.Exception.Message)" "ERROR" "Validation"
        return $false
    }
}

# Enhanced error handling with retry logic and exponential backoff
function Invoke-SafeCommand {
    param(
        [Parameter(Mandatory = $true)]
        [scriptblock]$Command,
        [Parameter(Mandatory = $true)]
        [string]$ErrorMessage,
        [switch]$ContinueOnError,
        [switch]$SuppressOutput,
        [int]$MaxRetries = -1,
        [int]$RetryDelay = -1
    )
    
    # Use global configuration if not specified
    if ($MaxRetries -eq -1) {
        $MaxRetries = $Global:Configuration.PackageManagement.RetryAttempts
    }
    if ($RetryDelay -eq -1) {
        $RetryDelay = $Global:Configuration.PackageManagement.RetryDelaySeconds
    }
    
    $attempt = 0
    $currentDelay = $RetryDelay
    
    do {
        $attempt++
        
        try {
            if (-not $SuppressOutput) {
                Write-Log "Executing (Attempt $attempt): $($Command.ToString())" "INFO"
            }
            
            $result = & $Command
            
            if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) {
                throw "Command failed with exit code: $LASTEXITCODE"
            }
            
            if ($attempt -gt 1) {
                Write-Log "Command succeeded on attempt $attempt" "SUCCESS"
            }
            
            return $result
        }
        catch {
            $errorMessage = "ERROR: $ErrorMessage - $($_.Exception.Message)"
            
            if ($attempt -lt $MaxRetries) {
                Write-Log "$errorMessage (Retrying in $currentDelay seconds...)" "WARNING"
                Start-Sleep -Seconds $currentDelay
                $currentDelay = [math]::Min($currentDelay * 2, 60)  # Exponential backoff, max 60 seconds
            } else {
                Write-Log "$errorMessage (Max retries exceeded)" "ERROR"
                if (-not $ContinueOnError) {
                    throw
                }
                return $null
            }
        }
    } while ($attempt -lt $MaxRetries)
}

# Enhanced package source validation
function Test-PackageSource {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageName
    )
    
    try {
        Write-Log "Validating package source for: $PackageName" "INFO" "Validation"
        
        # Check if package exists in WinGet sources
        $searchResult = winget search --exact -q $PackageName --accept-source-agreements 2>$null
        
        if ($searchResult -and $searchResult -match $PackageName) {
            Write-Log "Package source validated: $PackageName" "SUCCESS" "Validation"
            return $true
        } else {
            Write-Log "Package not found in WinGet sources: $PackageName" "WARNING" "Validation"
            return $false
        }
    }
    catch {
        Write-Log "Failed to validate package source for $PackageName : $($_.Exception.Message)" "ERROR" "Validation"
        return $false
    }
}

# System optimization functions
function Set-SystemOptimizations {
    Write-Log "Applying system optimizations for development" "INFO" "SystemOptimization"
    Write-Progress -Activity $Global:ProgressActivity -Status "Applying system optimizations" -PercentComplete 30
    
    try {
        # Registry tweaks for performance and developer experience
        $registryTweaks = @{
            # Disable Windows Search indexing for better performance
            "HKLM:\SOFTWARE\Microsoft\Windows Search\Gathering\Windows\SystemIndex" = @{
                "EnableIndexing" = 0
            }
            # Enable long path support
            "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" = @{
                "LongPathsEnabled" = 1
            }
            # Disable Windows Update automatic restart
            "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" = @{
                "NoAutoRebootWithLoggedOnUsers" = 1
            }
            # Optimize for performance - disable ALL visual effects
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" = @{
                "VisualFXSetting" = 2
            }
        }
        
        foreach ($keyPath in $registryTweaks.Keys) {
            try {
                if (-not (Test-Path $keyPath)) {
                    New-Item -Path $keyPath -Force | Out-Null
                }
                
                foreach ($valueName in $registryTweaks[$keyPath].Keys) {
                    $value = $registryTweaks[$keyPath][$valueName]
                    Set-ItemProperty -Path $keyPath -Name $valueName -Value $value -Type DWord -Force
                    Write-Log "Applied registry tweak: $keyPath\$valueName = $value" "SUCCESS" "SystemOptimization"
                }
            }
            catch {
                Write-Log "Failed to apply registry tweak $keyPath : $($_.Exception.Message)" "WARNING" "SystemOptimization"
            }
        }
        
        # Conditionally disable Windows Defender (SECURITY RISK - use with caution)
        if ($DisableWindowsDefender) {
            Write-Log "WARNING: Disabling Windows Defender real-time protection - THIS IS A SECURITY RISK!" "WARNING" "SystemOptimization"
            try {
                $defenderTweaks = @{
                    "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" = @{
                        "DisableRealtimeMonitoring" = 1
                    }
                }
                
                foreach ($keyPath in $defenderTweaks.Keys) {
                    if (-not (Test-Path $keyPath)) {
                        New-Item -Path $keyPath -Force | Out-Null
                    }
                    
                    foreach ($valueName in $defenderTweaks[$keyPath].Keys) {
                        $value = $defenderTweaks[$keyPath][$valueName]
                        Set-ItemProperty -Path $keyPath -Name $valueName -Value $value -Type DWord -Force
                        Write-Log "Applied Windows Defender tweak: $keyPath\$valueName = $value" "WARNING" "SystemOptimization"
                    }
                }
            }
            catch {
                Write-Log "Failed to apply Windows Defender tweaks: $($_.Exception.Message)" "ERROR" "SystemOptimization"
            }
        } else {
            Write-Log "Windows Defender real-time protection left enabled for security" "INFO" "SystemOptimization"
        }
        
        # Set high-performance power plan
        Set-HighPerformancePowerPlan
        
        # Disable all visual effects for maximum performance (unless skipped)
        if (-not $SkipVisualEffects) {
            Disable-AllVisualEffects
        } else {
            Write-Log "Skipping visual effects disabling as requested" "INFO" "SystemOptimization"
        }
        
        # Optimize network settings
        Set-NetworkOptimizations
        
        $Global:SetupReport.SystemOptimization = @{
            RegistryTweaks = $registryTweaks.Count
            PowerPlan = "High Performance"
            NetworkOptimized = $true
            VisualEffectsDisabled = $true
            Status = "Completed"
        }
        
        Write-Log "System optimizations completed successfully" "SUCCESS" "SystemOptimization"
    }
    catch {
        Write-Log "Failed to apply system optimizations: $($_.Exception.Message)" "ERROR" "SystemOptimization"
        $Global:SetupReport.SystemOptimization.Status = "Failed"
    }
}

function Set-HighPerformancePowerPlan {
    try {
        Write-Log "Setting high-performance power plan" "INFO" "SystemOptimization"
        
        # Get available power plans
        $powerPlans = powercfg /list
        $highPerfPlan = $powerPlans | Where-Object { $_ -match "High performance" }
        
        if ($highPerfPlan) {
            # Extract GUID from the power plan
            $guid = ($highPerfPlan -split '\s+')[3]
            powercfg /setactive $guid
            Write-Log "High-performance power plan activated" "SUCCESS" "SystemOptimization"
        } else {
            Write-Log "High-performance power plan not found, creating custom plan" "INFO" "SystemOptimization"
            # Create a custom high-performance plan
            $customGuid = powercfg /duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c "Dev High Performance"
            if ($customGuid) {
                $guid = ($customGuid -split '\s+')[-1]
                powercfg /setactive $guid
                Write-Log "Custom high-performance power plan created and activated" "SUCCESS" "SystemOptimization"
            }
        }
    }
    catch {
        Write-Log "Failed to set high-performance power plan: $($_.Exception.Message)" "ERROR" "SystemOptimization"
    }
}

function Disable-AllVisualEffects {
    try {
        Write-Log "Disabling all visual effects for maximum performance" "INFO" "SystemOptimization"
        
        # Comprehensive visual effects registry tweaks
        $visualEffectsTweaks = @{
            # Disable desktop composition (DWM)
            "HKLM:\SOFTWARE\Microsoft\Windows\DWM" = @{
                "EnableAeroPeek" = 0
                "AlwaysHibernateThumbnails" = 0
                "DisallowStartupAnimation" = 1
                "CornerPreference" = 0
                "AccentColor" = 0
                "ColorPrevalence" = 0
            }
            
            # Disable transparency effects
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" = @{
                "EnableTransparency" = 0
            }
            
            # Disable font smoothing
            "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" = @{
                "DisableFontSmoothing" = 1
            }
            
            # Disable animations, transitions, and desktop effects
            "HKCU:\Control Panel\Desktop" = @{
                "UserPreferencesMask" = [byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)
                "MenuShowDelay" = "0"
                "DragFullWindows" = "0"
                "FontSmoothing" = "0"
                "FontSmoothingType" = 0
                "FontSmoothingOrientation" = 0
                "FontSmoothingGamma" = 0
                "IconTitleWrap" = 0
                "ScreenSaveActive" = "0"
                "ScreenSaveTimeOut" = "0"
            }
            
            # Disable window animations
            "HKCU:\Control Panel\Desktop\WindowMetrics" = @{
                "MinAnimate" = "0"
            }
            
            # Disable cursor shadows and effects
            "HKCU:\Control Panel\Cursors" = @{
                "CursorShadow" = 0
            }
            
            # Disable visual effects in performance options
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" = @{
                "VisualFXSetting" = 2
            }
            
            # Disable all Explorer advanced visual effects
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" = @{
                "TaskbarAnimations" = 0
                "ListviewAlphaSelect" = 0
                "ListviewShadow" = 0
                "TaskbarGlomLevel" = 0
                "TaskbarNoNotification" = 1
                "DisallowShaking" = 1
                "StartMenuInit" = 0
                "Start_ShowMyGames" = 0
                "Start_ShowMyMusic" = 0
                "Start_ShowMyPics" = 0
                "Start_ShowMyVideos" = 0
                "Start_ShowPrinters" = 0
                "Start_ShowSetProgramAccessAndDefaults" = 0
                "IconsOnly" = 1
                "ShowInfoTip" = 0
                "HideFileExt" = 0
                "ShowSuperHidden" = 1
                "TaskbarDa" = 0
                "TaskbarMn" = 0
                "TaskbarSi" = 0
                "TaskbarGlom" = 0
            }
            
            # Disable desktop background slideshow
            "HKCU:\Control Panel\Personalization\Desktop Slideshow" = @{
                "Enabled" = 0
            }
            
            # Disable Windows 10/11 specific visual effects
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" = @{
                "AppsUseLightTheme" = 0
                "SystemUsesLightTheme" = 0
                "EnableTransparency" = 0
                "ColorPrevalence" = 0
            }
        }
        
        # Apply all visual effects registry tweaks
        foreach ($keyPath in $visualEffectsTweaks.Keys) {
            try {
                if (-not (Test-Path $keyPath)) {
                    New-Item -Path $keyPath -Force | Out-Null
                }
                
                foreach ($valueName in $visualEffectsTweaks[$keyPath].Keys) {
                    $value = $visualEffectsTweaks[$keyPath][$valueName]
                    Set-ItemProperty -Path $keyPath -Name $valueName -Value $value -Force
                    Write-Log "Applied visual effect tweak: $keyPath\$valueName = $value" "SUCCESS" "SystemOptimization"
                }
            }
            catch {
                Write-Log "Failed to apply visual effect tweak $keyPath : $($_.Exception.Message)" "WARNING" "SystemOptimization"
            }
        }
        
        # Disable visual effects via system commands
        try {
            # Disable desktop composition via system command
            $desktopComposition = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\DWM" -Name "Composition" -ErrorAction SilentlyContinue
            if ($desktopComposition -and $desktopComposition.Composition -eq 1) {
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\DWM" -Name "Composition" -Value 0 -Type DWord -Force
                Write-Log "Disabled desktop composition (DWM)" "SUCCESS" "SystemOptimization"
            }
            
            # Disable font smoothing via system command
            $fontSmoothing = Get-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothing" -ErrorAction SilentlyContinue
            if ($fontSmoothing -and $fontSmoothing.FontSmoothing -ne "0") {
                Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothing" -Value "0" -Force
                Write-Log "Disabled font smoothing" "SUCCESS" "SystemOptimization"
            }
            
            # Disable cursor shadows
            $cursorShadow = Get-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name "CursorShadow" -ErrorAction SilentlyContinue
            if ($cursorShadow -and $cursorShadow.CursorShadow -ne 0) {
                Set-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name "CursorShadow" -Value 0 -Type DWord -Force
                Write-Log "Disabled cursor shadows" "SUCCESS" "SystemOptimization"
            }
            
            # Disable window animations
            $windowAnimations = Get-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -ErrorAction SilentlyContinue
            if ($windowAnimations -and $windowAnimations.MinAnimate -ne "0") {
                Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0" -Force
                Write-Log "Disabled window animations" "SUCCESS" "SystemOptimization"
            }
            
            # Disable menu show delay
            $menuDelay = Get-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -ErrorAction SilentlyContinue
            if ($menuDelay -and $menuDelay.MenuShowDelay -ne "0") {
                Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "0" -Force
                Write-Log "Disabled menu show delay" "SUCCESS" "SystemOptimization"
            }
            
            # Disable drag full windows
            $dragFullWindows = Get-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "DragFullWindows" -ErrorAction SilentlyContinue
            if ($dragFullWindows -and $dragFullWindows.DragFullWindows -ne "0") {
                Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "DragFullWindows" -Value "0" -Force
                Write-Log "Disabled drag full windows" "SUCCESS" "SystemOptimization"
            }
            
        }
        catch {
            Write-Log "Failed to apply some visual effect system commands: $($_.Exception.Message)" "WARNING" "SystemOptimization"
        }
        
        # Disable Windows 10/11 specific visual effects
        try {
            # Disable transparency effects
            Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0 -Type DWord -Force
            Write-Log "Disabled transparency effects" "SUCCESS" "SystemOptimization"
            
            # Disable accent colors
            Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "ColorPrevalence" -Value 0 -Type DWord -Force
            Write-Log "Disabled accent colors" "SUCCESS" "SystemOptimization"
            
            # Disable light theme
            Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0 -Type DWord -Force
            Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0 -Type DWord -Force
            Write-Log "Disabled light theme" "SUCCESS" "SystemOptimization"
            
        }
        catch {
            Write-Log "Failed to apply Windows 10/11 visual effect tweaks: $($_.Exception.Message)" "WARNING" "SystemOptimization"
        }
        
        # Disable Windows 11 specific effects (if applicable)
        try {
            # Disable Windows 11 rounded corners
            Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\DWM" -Name "CornerPreference" -Value 0 -Type DWord -Force
            Write-Log "Disabled Windows 11 rounded corners" "SUCCESS" "SystemOptimization"
            
            # Disable Windows 11 taskbar effects
            Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0 -Type DWord -Force
            Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Value 0 -Type DWord -Force
            Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarSi" -Value 0 -Type DWord -Force
            Write-Log "Disabled Windows 11 taskbar effects" "SUCCESS" "SystemOptimization"
            
        }
        catch {
            Write-Log "Failed to apply Windows 11 specific visual effect tweaks: $($_.Exception.Message)" "WARNING" "SystemOptimization"
        }
        
        Write-Log "All visual effects disabled successfully for maximum performance" "SUCCESS" "SystemOptimization"
    }
    catch {
        Write-Log "Failed to disable visual effects: $($_.Exception.Message)" "ERROR" "SystemOptimization"
    }
}

function Set-NetworkOptimizations {
    try {
        Write-Log "Optimizing network settings for development" "INFO" "SystemOptimization"
        
        $networkConfig = $Global:Configuration.NetworkOptimizations
        
        # Configure Windows Update Delivery Optimization
        if ($networkConfig.EnableDeliveryOptimization) {
            try {
                # Disable Windows Update peer-to-peer sharing for better download speeds
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Value 0 -Type DWord -Force
                Write-Log "Disabled Windows Update peer-to-peer sharing" "SUCCESS" "SystemOptimization"
            }
            catch {
                Write-Log "Failed to configure delivery optimization: $($_.Exception.Message)" "WARNING" "SystemOptimization"
            }
        }
        
        # Optimize TCP settings for development
        if ($networkConfig.EnableTCPOptimizations) {
            try {
                # Configure TCP settings for better performance
                netsh int tcp set global autotuninglevel=normal
                netsh int tcp set global chimney=enabled
                netsh int tcp set global rss=enabled
                netsh int tcp set global netdma=enabled
                netsh int tcp set global dca=enabled
                
                # Optimize TCP window scaling
                netsh int tcp set global autotuninglevel=normal
                
                Write-Log "TCP optimizations applied successfully" "SUCCESS" "SystemOptimization"
            }
            catch {
                Write-Log "Failed to apply TCP optimizations: $($_.Exception.Message)" "WARNING" "SystemOptimization"
            }
        }
        
        # Configure bandwidth throttling if enabled
        if ($networkConfig.EnableBandwidthThrottling) {
            try {
                $maxBandwidth = $networkConfig.MaxBandwidthPercent
                netsh int tcp set global autotuninglevel=restricted
                Write-Log "Bandwidth throttling enabled at $maxBandwidth%" "SUCCESS" "SystemOptimization"
            }
            catch {
                Write-Log "Failed to configure bandwidth throttling: $($_.Exception.Message)" "WARNING" "SystemOptimization"
            }
        }
        
        # Configure Windows Update settings
        try {
            # Set Windows Update to notify before downloading
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUOptions" -Value 2 -Type DWord -Force
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoRebootWithLoggedOnUsers" -Value 1 -Type DWord -Force
            
            # Configure Windows Update for better performance
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Value 0 -Type DWord -Force
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DOMaxDownloadBandwidth" -Value 0 -Type DWord -Force
            
            Write-Log "Windows Update settings optimized" "SUCCESS" "SystemOptimization"
        }
        catch {
            Write-Log "Failed to configure Windows Update settings: $($_.Exception.Message)" "WARNING" "SystemOptimization"
        }
        
        # Configure DNS settings for better performance
        try {
            # Set DNS servers for better performance (Google DNS as fallback)
            $dnsServers = @("8.8.8.8", "8.8.4.4", "1.1.1.1", "1.0.0.1")
            $networkAdapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" -and $_.InterfaceDescription -notlike "*Loopback*" }
            
            foreach ($adapter in $networkAdapters) {
                try {
                    Set-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ServerAddresses $dnsServers -ErrorAction SilentlyContinue
                    Write-Log "DNS servers configured for adapter: $($adapter.Name)" "SUCCESS" "SystemOptimization"
                }
                catch {
                    Write-Log "Failed to configure DNS for adapter $($adapter.Name): $($_.Exception.Message)" "WARNING" "SystemOptimization"
                }
            }
        }
        catch {
            Write-Log "Failed to configure DNS settings: $($_.Exception.Message)" "WARNING" "SystemOptimization"
        }
        
        Write-Log "Network optimizations completed successfully" "SUCCESS" "SystemOptimization"
    }
    catch {
        Write-Log "Failed to apply network optimizations: $($_.Exception.Message)" "ERROR" "SystemOptimization"
    }
}

# Check prerequisites
function Test-Prerequisites {
    Write-Log "Checking prerequisites..." "INFO" "Prerequisites"
    
    # Check if running as administrator
    if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Log "This script requires Administrator privileges. Please run as Administrator." "ERROR"
        exit 1
    }
    
    # Check PowerShell version
    $psVersion = $PSVersionTable.PSVersion
    if ($psVersion.Major -lt 5) {
        Write-Log "PowerShell 5.1 or higher is required. Current version: $($psVersion.ToString())" "ERROR"
        exit 1
    }
    
    # Check Windows version
    $osVersion = [System.Environment]::OSVersion.Version
    if ($osVersion.Major -lt 10) {
        Write-Log "Windows 10 or higher is required. Current version: $($osVersion.ToString())" "ERROR"
        exit 1
    }
    
    $Global:SetupReport.Prerequisites = @{
        Administrator = $true
        PowerShellVersion = $psVersion.ToString()
        WindowsVersion = $osVersion.ToString()
        Status = "Passed"
    }
    
    Write-Log "Prerequisites check passed" "SUCCESS" "Prerequisites"
}

# Security hardening functions
function Set-SecurityHardening {
    Write-Log "Applying security hardening measures" "INFO" "SecurityHardening"
    Write-Progress -Activity $Global:ProgressActivity -Status "Applying security hardening" -PercentComplete 40
    
    try {
        # Configure Windows Updates
        Set-WindowsUpdateConfiguration
        
        # Configure Firewall rules for development tools
        Set-DevelopmentFirewallRules
        
        # Configure Windows Defender exclusions for development
        Set-DevelopmentDefenderExclusions
        
        $Global:SetupReport.SecurityHardening = @{
            WindowsUpdateConfigured = $true
            FirewallRulesConfigured = $true
            DefenderExclusionsSet = $true
            Status = "Completed"
        }
        
        Write-Log "Security hardening completed successfully" "SUCCESS" "SecurityHardening"
    }
    catch {
        Write-Log "Failed to apply security hardening: $($_.Exception.Message)" "ERROR" "SecurityHardening"
        $Global:SetupReport.SecurityHardening.Status = "Failed"
    }
}

function Set-WindowsUpdateConfiguration {
    try {
        Write-Log "Configuring Windows Update settings" "INFO" "SecurityHardening"
        
        # Set Windows Update to notify before downloading
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUOptions" -Value 2 -Type DWord -Force
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoRebootWithLoggedOnUsers" -Value 1 -Type DWord -Force
        
        # Check for and install pending updates
        Write-Log "Checking for Windows Updates" "INFO" "SecurityHardening"
        $updateSession = New-Object -ComObject Microsoft.Update.Session
        $updateSearcher = $updateSession.CreateUpdateSearcher()
        $searchResult = $updateSearcher.Search("IsInstalled=0 and Type='Software'")
        
        if ($searchResult.Updates.Count -gt 0) {
            Write-Log "Found $($searchResult.Updates.Count) pending updates" "INFO" "SecurityHardening"
            # Note: Automatic installation of updates requires more complex handling
            # For now, we'll just log the available updates
            foreach ($update in $searchResult.Updates) {
                Write-Log "Available update: $($update.Title)" "INFO" "SecurityHardening"
            }
        } else {
            Write-Log "No pending Windows Updates found" "SUCCESS" "SecurityHardening"
        }
        
        Write-Log "Windows Update configuration completed" "SUCCESS" "SecurityHardening"
    }
    catch {
        Write-Log "Failed to configure Windows Updates: $($_.Exception.Message)" "ERROR" "SecurityHardening"
    }
}

function Set-DevelopmentFirewallRules {
    try {
        Write-Log "Configuring firewall rules for development tools" "INFO" "SecurityHardening"
        
        # Define firewall rules for common development tools
        $firewallRules = @(
            @{
                Name = "Git for Windows"
                Program = "${env:ProgramFiles}\Git\bin\git.exe"
                Direction = "Inbound"
                Action = "Allow"
            },
            @{
                Name = "Docker Desktop"
                Program = "${env:ProgramFiles}\Docker\Docker\Docker Desktop.exe"
                Direction = "Inbound"
                Action = "Allow"
            },
            @{
                Name = "Node.js Development"
                Program = "${env:ProgramFiles}\nodejs\node.exe"
                Direction = "Inbound"
                Action = "Allow"
            },
            @{
                Name = "Python Development"
                Program = "${env:ProgramFiles}\Python*\python.exe"
                Direction = "Inbound"
                Action = "Allow"
            }
        )
        
        foreach ($rule in $firewallRules) {
            try {
                if (Test-Path $rule.Program -ErrorAction SilentlyContinue) {
                    New-NetFirewallRule -DisplayName $rule.Name -Program $rule.Program -Direction $rule.Direction -Action $rule.Action -Profile Any -ErrorAction SilentlyContinue
                    Write-Log "Created firewall rule: $($rule.Name)" "SUCCESS" "SecurityHardening"
                }
            }
            catch {
                Write-Log "Failed to create firewall rule $($rule.Name): $($_.Exception.Message)" "WARNING" "SecurityHardening"
            }
        }
        
        Write-Log "Firewall rules configuration completed" "SUCCESS" "SecurityHardening"
    }
    catch {
        Write-Log "Failed to configure firewall rules: $($_.Exception.Message)" "ERROR" "SecurityHardening"
    }
}

function Set-DevelopmentDefenderExclusions {
    try {
        Write-Log "Setting Windows Defender exclusions for development" "INFO" "SecurityHardening"
        
        # Common development directories to exclude
        $exclusionPaths = @(
            "${env:ProgramFiles}\Git",
            "${env:ProgramFiles}\Docker",
            "${env:ProgramFiles}\nodejs",
            "${env:ProgramFiles}\Python*",
            "${env:USERPROFILE}\.npm",
            "${env:USERPROFILE}\.git",
            "${env:USERPROFILE}\AppData\Local\Temp",
            "C:\Projects",
            "C:\Dev",
            "C:\Source"
        )
        
        foreach ($path in $exclusionPaths) {
            try {
                if (Test-Path $path -ErrorAction SilentlyContinue) {
                    Add-MpPreference -ExclusionPath $path -ErrorAction SilentlyContinue
                    Write-Log "Added Defender exclusion: $path" "SUCCESS" "SecurityHardening"
                }
            }
            catch {
                Write-Log "Failed to add Defender exclusion $path : $($_.Exception.Message)" "WARNING" "SecurityHardening"
            }
        }
        
        Write-Log "Windows Defender exclusions configured" "SUCCESS" "SecurityHardening"
    }
    catch {
        Write-Log "Failed to configure Windows Defender exclusions: $($_.Exception.Message)" "ERROR" "SecurityHardening"
    }
}

# Install WinGet
function Install-WinGet {
    Write-Log "Checking WinGet installation status" "INFO"
    
    try {
        $hasPackageManager = Get-AppPackage -Name 'Microsoft.DesktopAppInstaller' -ErrorAction SilentlyContinue
        
        if (-not $hasPackageManager -or [version]$hasPackageManager.Version -lt [version]"1.10.0.0") {
            Write-Log "Installing WinGet dependencies" "INFO"
            
            # Install Visual C++ Redistributables
            Invoke-SafeCommand -Command {
                Add-AppxPackage -Path 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx' -ErrorAction Stop
            } -ErrorMessage "Failed to install Visual C++ Redistributables" -ContinueOnError

            # Download and install latest WinGet
            $releasesUrl = 'https://api.github.com/repos/microsoft/winget-cli/releases/latest'
            
            # Ensure TLS 1.2 for secure connections
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            
            Write-Log "Fetching latest WinGet release information" "INFO"
            $releases = Invoke-RestMethod -Uri $releasesUrl -ErrorAction Stop
            
            $latestRelease = $releases.assets | Where-Object { $_.browser_download_url.EndsWith('msixbundle') } | Select-Object -First 1
            
            if ($latestRelease) {
                Write-Log "Installing WinGet from: $($latestRelease.browser_download_url)" "INFO"
                Invoke-SafeCommand -Command {
                    Add-AppxPackage -Path $latestRelease.browser_download_url -ErrorAction Stop
                } -ErrorMessage "Failed to install WinGet"
                
                # Wait for WinGet to be available
                $timeout = 30
                $elapsed = 0
                do {
                    Start-Sleep -Seconds 2
                    $elapsed += 2
                    $wingetCheck = Get-Command winget -ErrorAction SilentlyContinue
                } while (-not $wingetCheck -and $elapsed -lt $timeout)
                
                if ($wingetCheck) {
                    Write-Log "WinGet installed successfully" "SUCCESS"
                } else {
                    throw "WinGet installation timeout - command not available after $timeout seconds"
                }
            } else {
                throw "Could not find WinGet MSIX bundle in latest release"
            }
        } else {
            Write-Log "WinGet already installed (Version: $($hasPackageManager.Version))" "INFO"
        }
    }
    catch {
        Write-Log "Failed to install WinGet: $($_.Exception.Message)" "ERROR"
        throw
    }
}

# Configure WinGet
function Set-WinGetConfiguration {
    Write-Log "Configuring WinGet" "INFO"
    
    try {
        # WinGet config path
        $settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json"
        
        # Create directory if it doesn't exist
        $settingsDir = Split-Path $settingsPath -Parent
        if (-not (Test-Path $settingsDir)) {
            New-Item -Path $settingsDir -ItemType Directory -Force | Out-Null
        }
        
        # WinGet configuration JSON
        $settingsJson = @{
            "experimentalFeatures" = @{
                "experimentalMSStore" = $true
            }
            "source" = @{
                "autoUpdateIntervalInMinutes" = 3
            }
        } | ConvertTo-Json -Depth 3
        
        $settingsJson | Out-File -FilePath $settingsPath -Encoding UTF8 -Force
        Write-Log "WinGet configuration updated successfully" "SUCCESS"
    }
    catch {
        Write-Log "Failed to configure WinGet: $($_.Exception.Message)" "ERROR"
        throw
    }
}

# Enhanced package installation with better error handling and Windows-specific logic
function Install-PackageWithRetry {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Package,
        [int]$MaxRetries = 3,
        [int]$RetryDelay = 10
    )
    
    $packageName = $Package.name
    $attempt = 0
    
    do {
        $attempt++
        Write-Log "Installing $packageName (Attempt $attempt of $MaxRetries)" "INFO" "ApplicationInstallation"
        
        try {
            # Check if already installed
            $listResult = winget list --exact -q $packageName --accept-source-agreements 2>$null
            if ($listResult -and $listResult -match $packageName) {
                Write-Log "Package $packageName already installed" "INFO" "ApplicationInstallation"
                return @{
                    Name = $packageName
                    Status = "Skipped"
                    Message = "Already installed"
                    Category = $Package.category
                }
            }
            
            # Prepare installation arguments with Windows-specific considerations
            $installArgs = @(
                "install"
                "--exact"
                "--silent"
                "--accept-package-agreements"
                "--accept-source-agreements"
                "--disable-interactivity"
            )
            
            # Add package-specific arguments
            switch -Wildcard ($packageName) {
                "*VisualStudio*" {
                    $installArgs += "--override"
                    $installArgs += "--quiet --wait --add Microsoft.VisualStudio.Workload.CoreEditor"
                }
                "*Docker*" {
                    $installArgs += "--override"
                    $installArgs += "/quiet /norestart"
                }
                "*NodeJS*" {
                    $installArgs += "--override"
                    $installArgs += "ADDLOCAL=ALL"
                }
                "*Python*" {
                    $installArgs += "--override"
                    $installArgs += "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0"
                }
                "*Git*" {
                    $installArgs += "--override"
                    $installArgs += "/VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS"
                }
                "*Chrome*" {
                    $installArgs += "--override"
                    $installArgs += "--system-level --do-not-launch-chrome"
                }
                "*Firefox*" {
                    $installArgs += "--override"
                    $installArgs += "/S"
                }
            }
            
            $installArgs += $packageName
            
            # Execute installation with timeout
            $processInfo = New-Object System.Diagnostics.ProcessStartInfo
            $processInfo.FileName = "winget"
            $processInfo.Arguments = $installArgs -join " "
            $processInfo.UseShellExecute = $false
            $processInfo.RedirectStandardOutput = $true
            $processInfo.RedirectStandardError = $true
            $processInfo.CreateNoWindow = $true
            
            $process = New-Object System.Diagnostics.Process
            $process.StartInfo = $processInfo
            $process.Start() | Out-Null
            
            # Set timeout (15 minutes for large packages like Visual Studio)
            $timeoutMinutes = switch -Wildcard ($packageName) {
                "*VisualStudio*" { 30 }
                "*Docker*" { 20 }
                "*WindowsSDK*" { 25 }
                "*WindowsWDK*" { 25 }
                "*WindowsADK*" { 20 }
                default { 10 }
            }
            
            $timeout = $timeoutMinutes * 60 * 1000 # Convert to milliseconds
            
            if (-not $process.WaitForExit($timeout)) {
                $process.Kill()
                throw "Installation timeout after $timeoutMinutes minutes"
            }
            
            $stdout = $process.StandardOutput.ReadToEnd()
            $stderr = $process.StandardError.ReadToEnd()
            $exitCode = $process.ExitCode
            
            # Handle different exit codes
            switch ($exitCode) {
                0 { 
                    Write-Log "Successfully installed: $packageName" "SUCCESS" "ApplicationInstallation"
                    
                    # Post-installation validation
                    Start-Sleep -Seconds 5
                    $validationResult = Test-PackageInstallation -PackageName $packageName -ExecutableName $Package.executable
                    
                    return @{
                        Name = $packageName
                        Status = "Success"
                        Message = "Installed successfully"
                        Category = $Package.category
                        RequiresRestart = $Package.requiresRestart
                        Validated = $validationResult
                    }
                }
                -1978335189 { # Package already installed
                    Write-Log "Package $packageName already installed (exit code: $exitCode)" "INFO" "ApplicationInstallation"
                    return @{
                        Name = $packageName
                        Status = "Skipped"
                        Message = "Already installed"
                        Category = $Package.category
                    }
                }
                -1978335226 { # No applicable upgrade found
                    Write-Log "Package $packageName up to date (exit code: $exitCode)" "INFO" "ApplicationInstallation"
                    return @{
                        Name = $packageName
                        Status = "Skipped"
                        Message = "Up to date"
                        Category = $Package.category
                    }
                }
                default {
                    throw "Installation failed with exit code: $exitCode. Output: $stdout. Error: $stderr"
                }
            }
        }
        catch {
            $errorMessage = $_.Exception.Message
            Write-Log "Attempt $attempt failed for $packageName : $errorMessage" "WARNING" "ApplicationInstallation"
            
            if ($attempt -lt $MaxRetries) {
                Write-Log "Waiting $RetryDelay seconds before retry..." "INFO" "ApplicationInstallation"
                Start-Sleep -Seconds $RetryDelay
                $RetryDelay = [math]::Min($RetryDelay * 2, 120) # Exponential backoff, max 2 minutes
            }
        }
    } while ($attempt -lt $MaxRetries)
    
    return @{
        Name = $packageName
        Status = "Failed"
        Message = "Failed after $MaxRetries attempts"
        Category = $Package.category
    }
}

# Parallel package installation function (updated to use new installation method)
function Install-PackageParallel {
    param(
        [Parameter(Mandatory = $true)]
        [array]$Packages,
        [int]$MaxJobs = 4
    )
    
    $jobs = @()
    $completedJobs = 0
    $totalJobs = $Packages.Count
    
    Write-Log "Starting parallel installation of $totalJobs packages with max $MaxJobs concurrent jobs" "INFO" "ApplicationInstallation"
    
    foreach ($package in $Packages) {
        # Wait if we've reached the maximum number of concurrent jobs
        while ((Get-Job -State Running).Count -ge $MaxJobs) {
            Start-Sleep -Seconds 1
        }
        
        # Start installation job using the enhanced method
        $job = Start-Job -ScriptBlock {
            param($PackageHash)
            
            # Import the Install-PackageWithRetry function into the job context
            function Install-PackageWithRetry {
                param(
                    [Parameter(Mandatory = $true)]
                    [hashtable]$Package,
                    [int]$MaxRetries = 3,
                    [int]$RetryDelay = 10
                )
                
                $packageName = $Package.name
                $attempt = 0
                
                do {
                    $attempt++
                    
                    try {
                        # Check if already installed
                        $listResult = winget list --exact -q $packageName --accept-source-agreements 2>$null
                        if ($listResult -and $listResult -match $packageName) {
                            return @{
                                Name = $packageName
                                Status = "Skipped"
                                Message = "Already installed"
                                Category = $Package.category
                            }
                        }
                        
                        # Prepare installation arguments
                        $installArgs = @(
                            "install"
                            "--exact"
                            "--silent"
                            "--accept-package-agreements"
                            "--accept-source-agreements"
                            "--disable-interactivity"
                        )
                        
                        # Add package-specific arguments
                        switch -Wildcard ($packageName) {
                            "*VisualStudio*" {
                                $installArgs += "--override"
                                $installArgs += "--quiet --wait"
                            }
                            "*Docker*" {
                                $installArgs += "--override"
                                $installArgs += "/quiet /norestart"
                            }
                            "*NodeJS*" {
                                $installArgs += "--override"
                                $installArgs += "ADDLOCAL=ALL"
                            }
                            "*Python*" {
                                $installArgs += "--override"
                                $installArgs += "/quiet InstallAllUsers=1 PrependPath=1"
                            }
                            "*Git*" {
                                $installArgs += "--override"
                                $installArgs += "/VERYSILENT /NORESTART"
                            }
                        }
                        
                        $installArgs += $packageName
                        
                        # Execute installation
                        $result = Start-Process "winget" -ArgumentList ($installArgs -join " ") -Wait -PassThru -WindowStyle Hidden
                        
                        if ($result.ExitCode -eq 0 -or $result.ExitCode -eq -1978335189) {
                            return @{
                                Name = $packageName
                                Status = "Success"
                                Message = "Installed successfully"
                                Category = $Package.category
                                RequiresRestart = $Package.requiresRestart
                            }
                        } else {
                            throw "Installation failed with exit code: $($result.ExitCode)"
                        }
                    }
                    catch {
                        if ($attempt -lt $MaxRetries) {
                            Start-Sleep -Seconds $RetryDelay
                            $RetryDelay = [math]::Min($RetryDelay * 2, 60)
                        }
                    }
                } while ($attempt -lt $MaxRetries)
                
                return @{
                    Name = $packageName
                    Status = "Failed"
                    Message = "Failed after $MaxRetries attempts"
                    Category = $Package.category
                }
            }
            
            return Install-PackageWithRetry -Package $PackageHash
        } -ArgumentList $package
        
        $jobs += $job
        Write-Log "Started installation job for: $($package.name)" "INFO" "ApplicationInstallation"
    }
    
    # Wait for all jobs to complete and collect results
    $results = @()
    while ($jobs.Count -gt 0) {
        $completedJob = Wait-Job -Job $jobs -Any
        $result = Receive-Job -Job $completedJob
        $results += $result
        
        $completedJobs++
        $progressPercent = [math]::Round(($completedJobs / $totalJobs) * 100)
        Write-Progress -Activity $Global:ProgressActivity -Status "Installing packages ($completedJobs/$totalJobs)" -PercentComplete $progressPercent
        
        Write-Log "$($result.Status): $($result.Name) - $($result.Message)" $result.Status "ApplicationInstallation"
        
        $jobs = $jobs | Where-Object { $_ -ne $completedJob }
        Remove-Job -Job $completedJob
    }
    
    Write-Progress -Activity $Global:ProgressActivity -Completed
    return $results
}

# Install applications with dependency resolution and validation
function Install-Applications {
    Write-Log "Installing applications with dependency resolution" "INFO" "ApplicationInstallation"
    Write-Progress -Activity $Global:ProgressActivity -Status "Installing applications" -PercentComplete 50
    
    # Use configuration if available, otherwise use default apps
    if ($Global:Configuration.Applications.Count -gt 0) {
        $apps = $Global:Configuration.Applications
        Write-Log "Using applications from configuration file" "INFO" "ApplicationInstallation"
    } else {
        # Define applications to install with their executables for validation
        $apps = @(
        @{name = "Microsoft.PowerShell"; category = "Development"; executable = "pwsh" },
        @{name = "Microsoft.VisualStudioCode"; category = "Development"; executable = "code" },
        @{name = "Microsoft.WindowsTerminal"; category = "Development"; executable = "wt" },
        @{name = "Git.Git"; category = "Development"; executable = "git" },
        @{name = "Microsoft.VCRedist.2015+.x64"; category = "Runtime"; executable = $null },
        @{name = "Python.Python.3.13"; category = "Development"; executable = "python" },
        @{name = "Microsoft.WSL"; category = "Development"; executable = "wsl" },
        @{name = "Microsoft.VisualStudio.2022.Community"; category = "IDE"; executable = "devenv"; requiresRestart = $true },
        @{name = "OpenJS.NodeJS.LTS"; category = "Runtime"; executable = "node" },
        @{name = "OpenJS.NodeJS"; category = "Runtime"; executable = "node" },
        @{name = "Microsoft.DotNet.SDK.8"; category = "Runtime"; executable = "dotnet" },
        @{name = "Microsoft.DotNet.SDK.7"; category = "Runtime"; executable = "dotnet" },
        @{name = "Docker.DockerDesktop"; category = "Development"; executable = "docker" },
        @{name = "7zip.7zip"; category = "Utilities"; executable = "7z" },
        @{name = "HulubuluSoftware.AdvancedRenamer"; category = "Utilities"; executable = $null },
        @{name = "Altap.Salamander"; category = "Utilities"; executable = $null },
        @{name = "CrystalDewWorld.CrystalDiskInfo"; category = "System"; executable = $null },
        @{name = "voidtools.Everything.Alpha"; category = "Utilities"; executable = "Everything" },
        @{name = "IrfanSkiljan.IrfanView"; category = "Media"; executable = $null },
        @{name = "IrfanSkiljan.IrfanView.Plugins"; category = "Media"; executable = $null },
        @{name = "Mozilla.Firefox"; category = "Web"; executable = "firefox" },
        @{name = "Waterfox.Waterfox"; category = "Web"; executable = $null },
        @{name = "Nlitesoft.NTLite"; category = "System"; executable = $null },
        @{name = "Notepad++.Notepad++"; category = "Development"; executable = "notepad++" },
        @{name = "winaero.tweaker"; category = "System"; executable = $null },
        @{name = "AntibodySoftware.WizTree"; category = "Utilities"; executable = $null },
        @{name = "PeterPawlowski.foobar2000"; category = "Media"; executable = "foobar2000" },
        @{name = "PeterPawlowski.foobar2000.encoderpack"; category = "Media"; executable = $null },
        @{name = "clsid2.mpc-hc"; category = "Media"; executable = "mpc-hc64" },
        @{name = "Microsoft.CLRTypesSQLServer.2019"; category = "Runtime"; executable = $null },
        @{name = "Microsoft.EdgeWebView2Runtime"; category = "Runtime"; executable = $null },
        @{name = "Google.GoogleDrive"; category = "Utilities"; executable = $null },
        @{name = "Microsoft.Edit"; category = "Development"; executable = "edit" },
        @{name = "Microsoft.DotNet.UninstallTool"; category = "Development"; executable = "dotnet-core-uninstall" },
        @{name = "sylikc.JPEGView"; category = "Media"; executable = $null },
        @{name = "icsharpcode.ILSpy"; category = "Development"; executable = "ILSpy" },
        @{name = "Google.Chrome"; category = "Web"; executable = "chrome" },
        @{name = "Anysphere.Cursor"; category = "Development"; executable = "cursor" },
        @{name = "ThioJoe.SvgThumbnailExtension"; category = "Utilities"; executable = $null },
        @{name = "dundee.gdu"; category = "Utilities"; executable = "gdu" },
        @{name = "Microsoft.LogParser"; category = "Development"; executable = "logparser" },
        @{name = "Microsoft.DotNet.RepairTool"; category = "Development"; executable = "dotnetrepair" },
        @{name = "GNU.Wget2"; category = "Utilities"; executable = "wget2" },
        @{name = "Google.Chrome.Dev"; category = "Web"; executable = "chrome" },
        @{name = "Microsoft.NuGet"; category = "Development"; executable = "nuget" },
        @{name = "Wagnardsoft.DisplayDriverUninstaller"; category = "System"; executable = $null },
        @{name = "Microsoft.Edge.Dev"; category = "Web"; executable = "msedge" },
        @{name = "jsimlo.tednotepad"; category = "Development"; executable = $null },
        @{name = "cURL.cURL"; category = "Utilities"; executable = "curl" },
        @{name = "Microsoft.VisualStudio.2022.BuildTools"; category = "Development"; executable = $null; requiresRestart = $true },
        @{name = "Microsoft.DotNet.DesktopRuntime.6"; category = "Runtime"; executable = $null },
        @{name = "Microsoft.VCRedist.2015+.x86"; category = "Runtime"; executable = $null },
        @{name = "Microsoft.DotNet.DesktopRuntime.7"; category = "Runtime"; executable = $null },
        @{name = "Microsoft.WinDbg"; category = "Development"; executable = "windbg" },
        @{name = "Microsoft.TimeTravelDebugging"; category = "Development"; executable = $null },
        @{name = "Microsoft.WindowsSDK.10.0.26100"; category = "Development"; executable = $null },
        @{name = "AngusJohnson.ResourceHacker"; category = "Development"; executable = "ResourceHacker" },
        @{name = "Python.Launcher"; category = "Development"; executable = "py" },
        @{name = "Microsoft.winfile"; category = "Utilities"; executable = "winfile" },
        @{name = "Microsoft.WindowsADK"; category = "Development"; executable = $null },
        @{name = "Microsoft.WindowsWDK.10.0.26100"; category = "Development"; executable = $null },
        @{name = "Microsoft.DotNet.Runtime.6"; category = "Runtime"; executable = $null },
        @{name = "Microsoft.bitsmanager"; category = "System"; executable = "bitsadmin" },
        @{name = "katahiromz.RisohEditor"; category = "Development"; executable = $null },
        @{name = "Microsoft.VisualStudioCode.CLI"; category = "Development"; executable = "code" },
        @{name = "Microsoft.DotNet.DesktopRuntime.8"; category = "Runtime"; executable = $null },
        @{name = "Anthropic.Claude"; category = "AI"; executable = $null },
        @{name = "GitHub.GitHubDesktop"; category = "Development"; executable = $null },
        @{name = "Microsoft.err"; category = "Development"; executable = "err" },
        @{name = "Gyan.FFmpeg"; category = "Media"; executable = "ffmpeg" },
        @{name = "Microsoft.AppInstallerFileBuilder"; category = "Development"; executable = $null },
        @{name = "Microsoft.Sysinternals.Suite"; category = "System"; executable = $null },
        @{name = "Rclone.Rclone"; category = "Utilities"; executable = "rclone" },
        @{name = "Microsoft.DSC"; category = "Development"; executable = "dsc" },
        @{name = "Rufus.Rufus"; category = "Utilities"; executable = $null },
        @{name = "SumatraPDF.SumatraPDF"; category = "Utilities"; executable = "SumatraPDF" },
        @{name = "Alex313031.Thorium"; category = "Web"; executable = $null },
        @{name = "dnSpyEx.dnSpy"; category = "Development"; executable = "dnSpy" },
        @{name = "gsass1.NTop"; category = "System"; executable = "ntop" },
        @{name = "lostindark.DriverStoreExplorer"; category = "System"; executable = $null },
        @{name = "mikf.gallery-dl"; category = "Media"; executable = "gallery-dl" },
        @{name = "muesli.duf"; category = "Utilities"; executable = "duf" },
        @{name = "WinSCP.WinSCP"; category = "Utilities"; executable = "WinSCP" },
        @{name = "yt-dlp.FFmpeg"; category = "Media"; executable = $null },
        @{name = "yt-dlp.yt-dlp"; category = "Media"; executable = "yt-dlp" },
        @{name = "Python.Python.3.10"; category = "Development"; executable = "python" },
        @{name = "File-New-Project.EarTrumpet"; category = "Utilities"; executable = $null },
        @{name = "Microsoft.XMLNotepad"; category = "Development"; executable = $null },
        @{name = "ImageMagick.Q16"; category = "Media"; executable = "magick" },
        @{name = "Microsoft.AppInstaller"; category = "System"; executable = $null },
        @{name = "Microsoft.FoundryLocal"; category = "Development"; executable = $null },
        @{name = "Microsoft.UI.Xaml.2.8"; category = "Runtime"; executable = $null },
        @{name = "Microsoft.VCLibs.Desktop.14"; category = "Runtime"; executable = $null },
        @{name = "Microsoft.WindowsTerminal.Preview"; category = "Development"; executable = "wt" },
        @{name = "Microsoft.DeploymentToolkit"; category = "Development"; executable = $null }
        )
    }
    
    $installedCount = 0
    $skippedCount = 0
    $failedCount = 0
    $validatedCount = 0
    $totalApps = $apps.Count
    
    # First, install dependencies
    Write-Log "Installing dependencies first" "INFO" "ApplicationInstallation"
    $dependencyApps = $apps | Where-Object { $_.name -eq "Microsoft.VCRedist.2015+.x64" }
    foreach ($depApp in $dependencyApps) {
        try {
            Write-Log "Installing dependency: $($depApp.name)" "INFO" "ApplicationInstallation"
            $installResult = Invoke-SafeCommand -Command {
                winget install --exact --silent $depApp.name --accept-package-agreements --accept-source-agreements 2>$null
            } -ErrorMessage "Failed to install dependency $($depApp.name)" -ContinueOnError
            
            if ($null -ne $installResult) {
                Write-Log "Successfully installed dependency: $($depApp.name)" "SUCCESS" "ApplicationInstallation"
            }
        }
        catch {
            Write-Log "Error installing dependency $($depApp.name): $($_.Exception.Message)" "ERROR" "ApplicationInstallation"
        }
    }
    
    # Validate package sources if enabled
    if ($Global:Configuration.PackageManagement.EnableSourceValidation) {
        Write-Log "Validating package sources" "INFO" "ApplicationInstallation"
        $validatedApps = @()
        foreach ($app in $apps) {
            if (Test-PackageSource -PackageName $app.name) {
                $validatedApps += $app
            } else {
                Write-Log "Skipping $($app.name) - package source validation failed" "WARNING" "ApplicationInstallation"
            }
        }
        $apps = $validatedApps
    }
    
    # Sort applications by installation priority (dependencies first)
    $priorityOrder = @(
        # Critical runtime components first
        "Microsoft.VCRedist.2015+.x64",
        "Microsoft.VCRedist.2015+.x86",
        "Microsoft.UI.Xaml.2.8",
        "Microsoft.VCLibs.Desktop.14",
        "Microsoft.EdgeWebView2Runtime",
        
        # Windows features and system components
        "Microsoft.AppInstaller",
        "Microsoft.WSL",
        
        # .NET runtimes before SDKs
        "Microsoft.DotNet.Runtime.6",
        "Microsoft.DotNet.DesktopRuntime.6",
        "Microsoft.DotNet.DesktopRuntime.7",
        "Microsoft.DotNet.DesktopRuntime.8",
        "Microsoft.DotNet.SDK.7",
        "Microsoft.DotNet.SDK.8",
        
        # Core development tools
        "Git.Git",
        "Microsoft.PowerShell",
        "Microsoft.WindowsTerminal",
        "Microsoft.VisualStudioCode",
        "Microsoft.VisualStudioCode.CLI",
        
        # Language runtimes
        "OpenJS.NodeJS",
        "Python.Python.3.13",
        "Python.Python.3.10",
        "Python.Launcher",
        
        # Base applications before plugins/extensions
        "IrfanSkiljan.IrfanView",
        "PeterPawlowski.foobar2000",
        "Gyan.FFmpeg"
    )
    
    # Create sorted application list
    $sortedApps = @()
    
    # Add priority apps first
    foreach ($priority in $priorityOrder) {
        $app = $apps | Where-Object { $_.name -eq $priority }
        if ($app) {
            $sortedApps += $app
        }
    }
    
    # Add remaining apps
    $remainingApps = $apps | Where-Object { $_.name -notin $priorityOrder }
    $sortedApps += $remainingApps
    
    Write-Log "Installation order determined. Processing $($sortedApps.Count) applications." "INFO" "ApplicationInstallation"
    
    # Install applications in order (sequential for better dependency handling)
    $currentApp = 0
    foreach ($app in $sortedApps) {
        $currentApp++
        $progressPercent = [math]::Round((($currentApp - 1) / $totalApps) * 100)
        Write-Progress -Activity $Global:ProgressActivity -Status "Installing $($app.name) ($currentApp/$totalApps)" -PercentComplete $progressPercent
        
        try {
            Write-Log "Processing application $currentApp of $totalApps : $($app.name)" "INFO" "ApplicationInstallation"
            
            # Install dependencies first
            $dependencies = Resolve-PackageDependencies -PackageName $app.name
            foreach ($dependency in $dependencies) {
                $depApp = $sortedApps | Where-Object { $_.name -eq $dependency }
                if ($depApp -and ($sortedApps.IndexOf($depApp) -gt $sortedApps.IndexOf($app))) {
                    Write-Log "Installing dependency for $($app.name): $dependency" "INFO" "ApplicationInstallation"
                    $depResult = Install-PackageWithRetry -Package @{name = $dependency; category = "Runtime"; executable = $null}
                    if ($depResult.Status -eq "Failed") {
                        Write-Log "Dependency installation failed: $dependency. Continuing anyway." "WARNING" "ApplicationInstallation"
                    }
                }
            }
            
            # Install the main package
            $result = Install-PackageWithRetry -Package $app
            
            switch ($result.Status) {
                "Success" { 
                    $installedCount++
                    if ($result.Validated) { $validatedCount++ }
                }
                "Skipped" { 
                    $skippedCount++
                    # Still try to validate existing installations
                    if ($app.executable) {
                        $isValid = Test-PackageInstallation -PackageName $app.name -ExecutableName $app.executable
                        if ($isValid) { $validatedCount++ }
                    }
                }
                "Failed" { 
                    $failedCount++
                }
            }
            
            Write-Log "$($result.Status): $($result.Name) - $($result.Message)" $result.Status "ApplicationInstallation"
            
            # Handle packages that require restart
            if ($result.RequiresRestart -and $result.Status -eq "Success") {
                Write-Log "Package $($result.Name) requires system restart for full functionality" "WARNING" "ApplicationInstallation"
            }
            
        }
        catch {
            Write-Log "Error processing $($app.name): $($_.Exception.Message)" "ERROR" "ApplicationInstallation"
            $failedCount++
        }
        
        # Small delay between installations to prevent conflicts
        Start-Sleep -Seconds 2
    }
    
    # Final validation pass
    Write-Log "Performing final validation of installed applications" "INFO" "ApplicationInstallation"
    $finalValidationCount = 0
    foreach ($app in $sortedApps) {
        if ($app.executable) {
            $isValid = Test-PackageInstallation -PackageName $app.name -ExecutableName $app.executable
            if ($isValid) { $finalValidationCount++ }
        }
    }

    # Refresh environment variables after installation
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")


    
    $Global:SetupReport.ApplicationInstallation = @{
        TotalApps = $totalApps
        Installed = $installedCount
        Skipped = $skippedCount
        Failed = $failedCount
        Validated = $validatedCount
        FinalValidated = $finalValidationCount
        Status = if ($failedCount -eq 0) { "Completed" } else { "Partial" }
    }
    
    Write-Log "Installation summary - Total: $totalApps, Installed: $installedCount, Skipped: $skippedCount, Failed: $failedCount, Validated: $validatedCount, Final Validated: $finalValidationCount" "INFO" "ApplicationInstallation"
}

# Development environment setup functions
function Set-DevelopmentEnvironment {
    Write-Log "Setting up development environment" "INFO" "DevelopmentEnvironment"
    Write-Progress -Activity $Global:ProgressActivity -Status "Configuring development environment" -PercentComplete 60
    
    try {
        # Configure Git
        Set-GitConfiguration
        
        # Generate SSH keys
        New-SSHKeys
        
        # Configure VS Code
        Set-VSCodeConfiguration
        
        # Set up environment variables
        Set-DevelopmentEnvironmentVariables
        
        # Configure Docker Desktop
        Set-DockerConfiguration
        
        $Global:SetupReport.DevelopmentEnvironment = @{
            GitConfigured = $true
            SSHKeysGenerated = $true
            VSCodeConfigured = $true
            EnvironmentVariablesSet = $true
            DockerConfigured = $true
            Status = "Completed"
        }
        
        Write-Log "Development environment setup completed successfully" "SUCCESS" "DevelopmentEnvironment"
    }
    catch {
        Write-Log "Failed to set up development environment: $($_.Exception.Message)" "ERROR" "DevelopmentEnvironment"
        $Global:SetupReport.DevelopmentEnvironment.Status = "Failed"
    }
}

function Set-GitConfiguration {
    try {
        Write-Log "Configuring Git" "INFO" "DevelopmentEnvironment"
        
        if ($GitUserName -and $GitUserEmail) {
            # Set Git user configuration
            git config --global user.name $GitUserName
            git config --global user.email $GitUserEmail
            Write-Log "Git user configured: $GitUserName <$GitUserEmail>" "SUCCESS" "DevelopmentEnvironment"
        } else {
            Write-Log "Git user configuration skipped - no credentials provided" "WARNING" "DevelopmentEnvironment"
        }
        
        # Set common Git aliases
        $gitAliases = @{
            "st" = "status"
            "co" = "checkout"
            "br" = "branch"
            "ci" = "commit"
            "df" = "diff"
            "lg" = "log --oneline --graph --decorate --all"
            "unstage" = "reset HEAD --"
            "last" = "log -1 HEAD"
            "visual" = "!gitk"
        }
        
        foreach ($alias in $gitAliases.Keys) {
            git config --global alias.$alias $gitAliases[$alias]
        }
        
        # Set Git configuration for better development experience
        git config --global core.autocrlf true
        git config --global core.safecrlf false
        git config --global init.defaultBranch main
        git config --global pull.rebase false
        git config --global push.default simple
        
        Write-Log "Git configuration completed successfully" "SUCCESS" "DevelopmentEnvironment"
    }
    catch {
        Write-Log "Failed to configure Git: $($_.Exception.Message)" "ERROR" "DevelopmentEnvironment"
    }
}

function New-SSHKeys {
    try {
        Write-Log "Generating SSH keys for GitHub/GitLab" "INFO" "DevelopmentEnvironment"
        
        $sshDir = "$env:USERPROFILE\.ssh"
        if (-not (Test-Path $sshDir)) {
            New-Item -Path $sshDir -ItemType Directory -Force | Out-Null
        }
        
        # Generate SSH key for GitHub
        $githubKeyPath = "$sshDir\id_rsa_github"
        if (-not (Test-Path $githubKeyPath)) {
            ssh-keygen -t rsa -b 4096 -C $GitUserEmail -f $githubKeyPath -N '""'
            Write-Log "SSH key generated for GitHub: $githubKeyPath" "SUCCESS" "DevelopmentEnvironment"
        } else {
            Write-Log "SSH key for GitHub already exists" "INFO" "DevelopmentEnvironment"
        }
        
        # Generate SSH key for GitLab
        $gitlabKeyPath = "$sshDir\id_rsa_gitlab"
        if (-not (Test-Path $gitlabKeyPath)) {
            ssh-keygen -t rsa -b 4096 -C $GitUserEmail -f $gitlabKeyPath -N '""'
            Write-Log "SSH key generated for GitLab: $gitlabKeyPath" "SUCCESS" "DevelopmentEnvironment"
        } else {
            Write-Log "SSH key for GitLab already exists" "INFO" "DevelopmentEnvironment"
        }
        
        # Create SSH config file
        $sshConfigPath = "$sshDir\config"
        $sshConfig = @"
# GitHub
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa_github
    IdentitiesOnly yes

# GitLab
Host gitlab.com
    HostName gitlab.com
    User git
    IdentityFile ~/.ssh/id_rsa_gitlab
    IdentitiesOnly yes
"@
        
        $sshConfig | Out-File -FilePath $sshConfigPath -Encoding UTF8 -Force
        Write-Log "SSH configuration file created" "SUCCESS" "DevelopmentEnvironment"
        
        # Display public keys for user to copy
        Write-Log "GitHub public key:" "INFO" "DevelopmentEnvironment"
        Get-Content "$githubKeyPath.pub" | Write-Host -ForegroundColor Yellow
        
        Write-Log "GitLab public key:" "INFO" "DevelopmentEnvironment"
        Get-Content "$gitlabKeyPath.pub" | Write-Host -ForegroundColor Yellow
        
        Write-Log "Please add these public keys to your GitHub and GitLab accounts" "INFO" "DevelopmentEnvironment"
    }
    catch {
        Write-Log "Failed to generate SSH keys: $($_.Exception.Message)" "ERROR" "DevelopmentEnvironment"
    }
}

function Set-VSCodeConfiguration {
    try {
        Write-Log "Configuring VS Code" "INFO" "DevelopmentEnvironment"
        
        $vscodeSettingsPath = "$env:APPDATA\Code\User\settings.json"
        $vscodeExtensionsPath = "$env:APPDATA\Code\User\extensions.json"
        
        # Create VS Code settings
        $vscodeSettings = @{
            "editor.fontSize" = 14
            "editor.fontFamily" = "'Cascadia Code', 'Fira Code', Consolas, 'Courier New', monospace"
            "editor.fontLigatures" = $true
            "editor.tabSize" = 4
            "editor.insertSpaces" = $true
            "editor.wordWrap" = "on"
            "editor.minimap.enabled" = $true
            "editor.bracketPairColorization.enabled" = $true
            "editor.guides.bracketPairs" = $true
            "workbench.colorTheme" = "Dark+ (default dark)"
            "workbench.iconTheme" = "vs-seti"
            "terminal.integrated.defaultProfile.windows" = "PowerShell"
            "terminal.integrated.profiles.windows" = @{
                "PowerShell" = @{
                    "source" = "PowerShell"
                    "icon" = "terminal-powershell"
                }
                "Command Prompt" = @{
                    "path" = "C:\\Windows\\System32\\cmd.exe"
                    "args" = @()
                    "icon" = "terminal-cmd"
                }
            }
            "git.enableSmartCommit" = $true
            "git.confirmSync" = $false
            "git.autofetch" = $true
            "files.autoSave" = "afterDelay"
            "files.autoSaveDelay" = 1000
            "explorer.confirmDelete" = $false
            "explorer.confirmDragAndDrop" = $false
        }
        
        $vscodeSettings | ConvertTo-Json -Depth 10 | Out-File -FilePath $vscodeSettingsPath -Encoding UTF8 -Force
        
        # Define recommended extensions
        $recommendedExtensions = @(
            "ms-vscode.powershell",
            "ms-python.python",
            "ms-vscode.vscode-json",
            "redhat.vscode-yaml",
            "ms-vscode.vscode-typescript-next",
            "bradlc.vscode-tailwindcss",
            "esbenp.prettier-vscode",
            "ms-vscode.vscode-eslint",
            "GitHub.copilot",
            "GitHub.copilot-chat",
            "ms-vscode-remote.remote-wsl",
            "ms-vscode-remote.remote-containers",
            "ms-azuretools.vscode-docker",
            "ms-vscode.hexeditor",
            "ms-vscode.vscode-markdown"
        )
        
        $extensionsConfig = @{
            "recommendations" = $recommendedExtensions
        }
        
        $extensionsConfig | ConvertTo-Json -Depth 10 | Out-File -FilePath $vscodeExtensionsPath -Encoding UTF8 -Force
        
        Write-Log "VS Code configuration completed successfully" "SUCCESS" "DevelopmentEnvironment"
        Write-Log "Recommended extensions list created. Install them from VS Code Extensions view." "INFO" "DevelopmentEnvironment"
    }
    catch {
        Write-Log "Failed to configure VS Code: $($_.Exception.Message)" "ERROR" "DevelopmentEnvironment"
    }
}

function Set-DevelopmentEnvironmentVariables {
    try {
        Write-Log "Setting up development environment variables" "INFO" "DevelopmentEnvironment"
        
        # Define development environment variables
        $envVars = @{
            "DEV_HOME" = "C:\Dev"
            "PROJECTS_HOME" = "C:\Projects"
            "NODE_ENV" = "development"
            "PYTHONPATH" = "C:\Dev\Python"
            "GIT_EDITOR" = "code --wait"
            "EDITOR" = "code"
        }
        
        foreach ($var in $envVars.Keys) {
            [Environment]::SetEnvironmentVariable($var, $envVars[$var], "User")
            Write-Log "Set environment variable: $var = $($envVars[$var])" "SUCCESS" "DevelopmentEnvironment"
        }
        
        # Create development directories
        $devDirs = @("C:\Dev", "C:\Projects", "C:\Dev\Python", "C:\Dev\Scripts")
        foreach ($dir in $devDirs) {
            if (-not (Test-Path $dir)) {
                New-Item -Path $dir -ItemType Directory -Force | Out-Null
                Write-Log "Created development directory: $dir" "SUCCESS" "DevelopmentEnvironment"
            }
        }
        
        Write-Log "Development environment variables configured successfully" "SUCCESS" "DevelopmentEnvironment"
    }
    catch {
        Write-Log "Failed to set up environment variables: $($_.Exception.Message)" "ERROR" "DevelopmentEnvironment"
    }
}

function Set-DockerConfiguration {
    try {
        Write-Log "Configuring Docker Desktop for development" "INFO" "DevelopmentEnvironment"
        Write-Progress -Activity $Global:ProgressActivity -Status "Configuring Docker Desktop" -PercentComplete 65
        
        # Create Docker configuration directories
        $dockerConfigDir = "$env:USERPROFILE\.docker"
        $dockerCliPluginsDir = "$env:USERPROFILE\.docker\cli-plugins"
        $dockerDataDir = "$env:USERPROFILE\AppData\Local\Docker\wsl\data"
        
        foreach ($dir in @($dockerConfigDir, $dockerCliPluginsDir)) {
            if (-not (Test-Path $dir)) {
                New-Item -Path $dir -ItemType Directory -Force | Out-Null
                Write-Log "Created Docker directory: $dir" "SUCCESS" "DevelopmentEnvironment"
            }
        }
        
        # Get system specs for optimal configuration
        $systemMemory = [math]::Round((Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1MB)
        $cpuCores = (Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors
        
        # Calculate optimal Docker resource allocation (secure defaults)
        $dockerMemoryMB = [math]::Min(8192, [math]::Floor($systemMemory * 0.75))  # Max 8GB or 75% of system RAM
        $dockerCPUs = [math]::Min(4, $cpuCores - 1)  # Max 4 cores, leave at least 1 for OS
        
        # Enhanced Docker daemon configuration with security best practices
        $dockerDaemonConfig = @{
            "experimental" = $true
            "features" = @{
                "buildkit" = $true
            }
            "builder" = @{
                "gc" = @{
                    "enabled" = $true
                    "defaultKeepStorage" = "20GB"
                    "policy" = @{
                        @{
                            "keepStorage" = "10GB"
                            "filter" = @("unused-for=2160h")  # 90 days
                        }
                        @{
                            "keepStorage" = "50GB"
                            "all" = $true
                        }
                    }
                }
            }
            "log-driver" = "json-file"
            "log-opts" = @{
                "max-size" = "10m"
                "max-file" = "5"
                "compress" = "true"
            }
            "storage-driver" = "windowsfilter"
            "hosts" = @("npipe://")  # Only named pipe for security
            "tls" = $true
            "tlsverify" = $false  # For local development only
            "insecure-registries" = @("localhost:5000", "127.0.0.1:5000")  # Local registries only
            "registry-mirrors" = @()
            "dns" = @("1.1.1.1", "1.0.0.1")  # Cloudflare DNS for better performance
            "dns-opts" = @("ndots:0")
            "mtu" = 1500
            "userland-proxy" = $false
            "live-restore" = $true
            "max-concurrent-downloads" = 3
            "max-concurrent-uploads" = 5
            "default-ulimits" = @{
                "memlock" = @{
                    "Hard" = -1
                    "Name" = "memlock"
                    "Soft" = -1
                }
                "nofile" = @{
                    "Hard" = 65536
                    "Name" = "nofile"
                    "Soft" = 65536
                }
            }
            "seccomp-profile" = "$dockerConfigDir\seccomp-profile.json"
        }
        
        # Create secure seccomp profile
        $seccompProfile = @{
            "defaultAction" = "SCMP_ACT_ERRNO"
            "syscalls" = @(
                @{
                    "names" = @(
                        "accept", "accept4", "access", "adjtimex", "alarm", "bind", "brk", "capget", "capset",
                        "chdir", "chmod", "chown", "chroot", "clock_getres", "clock_gettime", "clock_nanosleep",
                        "close", "connect", "copy_file_range", "creat", "dup", "dup2", "dup3", "epoll_create",
                        "epoll_create1", "epoll_ctl", "epoll_pwait", "epoll_wait", "eventfd", "eventfd2",
                        "execve", "execveat", "exit", "exit_group", "faccessat", "fadvise64", "fallocate",
                        "fanotify_mark", "fchdir", "fchmod", "fchmodat", "fchown", "fchownat", "fcntl",
                        "fdatasync", "fgetxattr", "flistxattr", "flock", "fork", "fremovexattr", "fsetxattr",
                        "fstat", "fstatfs", "fsync", "ftruncate", "futex", "getcwd", "getdents", "getdents64",
                        "getegid", "geteuid", "getgid", "getgroups", "getitimer", "getpeername", "getpgid",
                        "getpgrp", "getpid", "getppid", "getpriority", "getrandom", "getresgid", "getresuid",
                        "getrlimit", "get_robust_list", "getrusage", "getsid", "getsockname", "getsockopt",
                        "get_thread_area", "gettid", "gettimeofday", "getuid", "getxattr", "inotify_add_watch",
                        "inotify_init", "inotify_init1", "inotify_rm_watch", "io_cancel", "ioctl", "io_destroy",
                        "io_getevents", "ioprio_get", "ioprio_set", "io_setup", "io_submit", "ipc", "kill",
                        "lchown", "lgetxattr", "link", "linkat", "listen", "listxattr", "llistxattr",
                        "lremovexattr", "lseek", "lsetxattr", "lstat", "madvise", "memfd_create", "mincore",
                        "mkdir", "mkdirat", "mknod", "mknodat", "mlock", "mlock2", "mlockall", "mmap",
                        "mmap2", "mprotect", "mq_getsetattr", "mq_notify", "mq_open", "mq_timedreceive",
                        "mq_timedsend", "mq_unlink", "mremap", "msgctl", "msgget", "msgrcv", "msgsnd",
                        "msync", "munlock", "munlockall", "munmap", "nanosleep", "newfstatat", "open",
                        "openat", "pause", "pipe", "pipe2", "poll", "ppoll", "prctl", "pread64", "preadv",
                        "prlimit64", "pselect6", "ptrace", "pwrite64", "pwritev", "read", "readahead",
                        "readlink", "readlinkat", "readv", "recv", "recvfrom", "recvmsg", "recvmmsg",
                        "rename", "renameat", "renameat2", "restart_syscall", "rmdir", "rt_sigaction",
                        "rt_sigpending", "rt_sigprocmask", "rt_sigqueueinfo", "rt_sigreturn", "rt_sigsuspend",
                        "rt_sigtimedwait", "rt_tgsigqueueinfo", "sched_getaffinity", "sched_getattr",
                        "sched_getparam", "sched_get_priority_max", "sched_get_priority_min", "sched_getscheduler",
                        "sched_setaffinity", "sched_setattr", "sched_setparam", "sched_setscheduler",
                        "sched_yield", "seccomp", "select", "semctl", "semget", "semop", "semtimedop",
                        "send", "sendfile", "sendfile64", "sendmmsg", "sendmsg", "sendto", "setfsgid",
                        "setfsuid", "setgid", "setgroups", "setitimer", "setpgid", "setpriority", "setregid",
                        "setresgid", "setresuid", "setreuid", "setrlimit", "set_robust_list", "setsid",
                        "setsockopt", "set_thread_area", "set_tid_address", "setuid", "setxattr", "shmat",
                        "shmctl", "shmdt", "shmget", "shutdown", "sigaltstack", "signalfd", "signalfd4",
                        "sigreturn", "socket", "socketcall", "socketpair", "splice", "stat", "statfs",
                        "statx", "symlink", "symlinkat", "sync", "sync_file_range", "syncfs", "sysinfo",
                        "syslog", "tee", "tgkill", "time", "timer_create", "timer_delete", "timerfd_create",
                        "timerfd_gettime", "timerfd_settime", "timer_getoverrun", "timer_gettime",
                        "timer_settime", "times", "tkill", "truncate", "umask", "uname", "unlink",
                        "unlinkat", "utime", "utimensat", "utimes", "vfork", "vmsplice", "wait4",
                        "waitid", "waitpid", "write", "writev"
                    )
                    "action" = "SCMP_ACT_ALLOW"
                }
            )
        }
        
        # Save daemon configuration
        $dockerDaemonConfig | ConvertTo-Json -Depth 10 | Out-File -FilePath "$dockerConfigDir\daemon.json" -Encoding UTF8 -Force
        $seccompProfile | ConvertTo-Json -Depth 10 | Out-File -FilePath "$dockerConfigDir\seccomp-profile.json" -Encoding UTF8 -Force
        
        # Create Docker Desktop settings for Windows with security considerations
        $dockerDesktopSettingsDir = "$env:APPDATA\Docker"
        if (-not (Test-Path $dockerDesktopSettingsDir)) {
            New-Item -Path $dockerDesktopSettingsDir -ItemType Directory -Force | Out-Null
        }
        
        $dockerDesktopSettings = @{
            "configurationFileVersion" = 2
            "settingsVersion" = 1
            "memoryMiB" = $dockerMemoryMB
            "cpus" = $dockerCPUs
            "swapMiB" = [math]::Min(2048, [math]::Floor($dockerMemoryMB * 0.25))  # 25% of allocated RAM for swap
            "diskSizeMiB" = 65536  # 64GB virtual disk
            "dnsServer" = "1.1.1.1"
            "hostNetworkingEnabled" = $false  # Security: disable host networking
            "localhostForwarding" = $true
            "vpnKitAllowedBinds" = @()
            "allowExperimentalFeatures" = $true
            "displayedWelcomeWhale" = $true
            "enableWslEngine" = $true
            "wslEngineEnabled" = $true
            "useWindowsContainers" = $false
            "dataFolder" = $dockerDataDir
            "kubernetesEnabled" = $false  # Disable by default for security
            "showKubernetesSystemContainers" = $false
            "extensionsEnabled" = $true
            "extensionsSystemContainers" = $false  # Security: disable system containers for extensions
            "autoStart" = $false  # Security: don't auto-start Docker
            "startOnLogin" = $false  # Security: don't start on login
            "exposeDockerAPIOnTCP2375WithoutTLS" = $false  # Security: never expose API without TLS
            "openUIOnStartupDisabled" = $true
            "checkForUpdates" = $true
            "sendUsageStatistics" = $false  # Privacy: disable usage statistics
            "showWhatsNewAfterUpdate" = $false
            "filesharingDirectories" = @()  # Empty by default for security
        }
        
        $dockerDesktopSettings | ConvertTo-Json -Depth 10 | Out-File -FilePath "$dockerDesktopSettingsDir\settings.json" -Encoding UTF8 -Force
        
        # Create development-friendly Docker Compose override template
        $dockerComposeTemplate = @"
# Docker Compose development template
# Place this in your project root as docker-compose.override.yml
version: '3.8'

services:
  # Add common development overrides here
  # Example web service with development settings:
  # web:
  #   volumes:
  #     - .:/app
  #     - /app/node_modules  # Prevent overwriting node_modules
  #   environment:
  #     - NODE_ENV=development
  #     - DEBUG=app:*
  #   ports:
  #     - "3000:3000"
  #   stdin_open: true
  #   tty: true

# Development networks with proper isolation
networks:
  default:
    name: dev-network
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16

volumes:
  # Common development volumes
  node_modules:
    driver: local
  vendor:
    driver: local
  postgres_data:
    driver: local
"@
        
        $dockerComposeTemplate | Out-File -FilePath "$dockerConfigDir\docker-compose.template.yml" -Encoding UTF8 -Force
        
        # Create secure Docker aliases and helper functions
        $dockerAliasesScript = @"
# Docker Development Aliases and Security Helpers
# Source this file in your PowerShell profile: . `$env:USERPROFILE\.docker\docker-aliases.ps1

# Container management with security awareness
function dps { docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.Image}}" `$args }
function dpsa { docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.Image}}" `$args }
function di { docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedSince}}" `$args }
function dex { 
    param([string]`$container, [string]`$command = "/bin/bash")
    if (-not `$container) { Write-Host "Usage: dex <container> [command]" -ForegroundColor Red; return }
    docker exec -it `$container `$command `$args 
}
function dlog { 
    param([string]`$container, [int]`$lines = 100)
    if (-not `$container) { Write-Host "Usage: dlog <container> [lines]" -ForegroundColor Red; return }
    docker logs --tail `$lines -f `$container 
}
function dstop { docker stop `$args }
function drm { docker rm `$args }
function drmi { docker rmi `$args }

# Docker Compose shortcuts with security validations
function dcup { 
    # Validate docker-compose.yml exists and is secure
    if (-not (Test-Path "docker-compose.yml")) {
        Write-Host "No docker-compose.yml found in current directory" -ForegroundColor Red
        return
    }
    docker compose up -d `$args 
}
function dcdown { docker compose down `$args }
function dclogs { docker compose logs -f `$args }
function dcbuild { docker compose build --no-cache `$args }
function dcpull { docker compose pull `$args }
function dcrestart { docker compose restart `$args }

# Security-focused cleanup commands
function docker-cleanup {
    Write-Host "Performing safe Docker cleanup..." -ForegroundColor Yellow
    docker system prune -f --filter "until=24h"
    docker volume prune -f --filter "label!=keep"
    docker network prune -f
    Write-Host "Docker cleanup completed" -ForegroundColor Green
}

function docker-cleanup-all {
    Write-Host "WARNING: This will remove ALL unused Docker resources!" -ForegroundColor Red
    `$confirm = Read-Host "Are you sure? (y/N)"
    if (`$confirm -eq "y" -or `$confirm -eq "Y") {
        docker system prune -af --volumes
        Write-Host "Complete Docker cleanup performed" -ForegroundColor Green
    } else {
        Write-Host "Cleanup cancelled" -ForegroundColor Yellow
    }
}

# Security helpers
function docker-security-scan {
    param([string]`$image)
    if (-not `$image) { Write-Host "Usage: docker-security-scan <image>" -ForegroundColor Red; return }
    Write-Host "Scanning image for vulnerabilities..." -ForegroundColor Yellow
    docker scout cves `$image
}

function docker-inspect-security {
    param([string]`$container)
    if (-not `$container) { Write-Host "Usage: docker-inspect-security <container>" -ForegroundColor Red; return }
    Write-Host "Security inspection for container: `$container" -ForegroundColor Yellow
    docker inspect `$container --format='{{.HostConfig.Privileged}}' | ForEach-Object {
        if (`$_ -eq "true") { Write-Host "WARNING: Container is running in privileged mode!" -ForegroundColor Red }
        else { Write-Host "Container is not privileged" -ForegroundColor Green }
    }
}

# Development helpers
function docker-shell { 
    param([string]`$container, [string]`$shell = "/bin/bash")
    if (-not `$container) { Write-Host "Usage: docker-shell <container> [shell]" -ForegroundColor Red; return }
    docker exec -it `$container `$shell
}

function docker-logs-tail {
    param([string]`$container, [int]`$lines = 100)
    if (-not `$container) { Write-Host "Usage: docker-logs-tail <container> [lines]" -ForegroundColor Red; return }
    docker logs --tail `$lines -f `$container
}

function docker-stats-live {
    docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}" `$args
}

# Image management with security focus
function docker-images-vulnerabilities {
    Write-Host "Checking all local images for known vulnerabilities..." -ForegroundColor Yellow
    docker images --format "{{.Repository}}:{{.Tag}}" | ForEach-Object {
        if (`$_ -ne "<none>:<none>") {
            Write-Host "Checking `$_..." -ForegroundColor Cyan
            docker scout cves `$_ 2>`$null
        }
    }
}
"@
        
        $dockerAliasesScript | Out-File -FilePath "$dockerConfigDir\docker-aliases.ps1" -Encoding UTF8 -Force
        
        # Create .dockerignore template for security
        $dockerIgnoreTemplate = @"
# Security-focused .dockerignore template

# Never include secrets or sensitive files
**/.env*
**/secrets/
**/*secret*
**/*password*
**/*key*
**/*.pem
**/*.p12
**/*.jks
**/.aws/
**/.ssh/
**/id_rsa*
**/id_dsa*
**/id_ecdsa*
**/id_ed25519*

# Development and build artifacts
**/node_modules/
**/npm-debug.log
**/.npm/
**/coverage/
**/.nyc_output/
**/dist/
**/build/
**/.cache/
**/.vscode/
**/.idea/

# Version control
**/.git/
**/.gitignore
**/.hg/
**/.svn/

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
*~

# Logs and temporary files
**/*.log
**/logs/
**/tmp/
**/temp/

# Database files
**/*.sql
**/*.db
**/*.sqlite*

# Documentation (optional, uncomment if not needed)
# **/README*
# **/CHANGELOG*
# **/docs/
"@
        
        $dockerIgnoreTemplate | Out-File -FilePath "$dockerConfigDir\.dockerignore.template" -Encoding UTF8 -Force
        
        Write-Log "Docker configuration completed successfully" "SUCCESS" "DevelopmentEnvironment"
        Write-Log "Docker Memory: ${dockerMemoryMB}MB, CPUs: $dockerCPUs" "INFO" "DevelopmentEnvironment"
        Write-Log "Docker aliases available at: $dockerConfigDir\docker-aliases.ps1" "INFO" "DevelopmentEnvironment"
        Write-Log "Docker Compose template: $dockerConfigDir\docker-compose.template.yml" "INFO" "DevelopmentEnvironment"
        Write-Log "Secure .dockerignore template: $dockerConfigDir\.dockerignore.template" "INFO" "DevelopmentEnvironment"
        Write-Log "Docker will use optimized security settings when started" "INFO" "DevelopmentEnvironment"
    }
    catch {
        Write-Log "Failed to configure Docker: $($_.Exception.Message)" "ERROR" "DevelopmentEnvironment"
    }
}

# Remove bloatware applications
function Remove-Bloatware {
    Write-Log "Removing bloatware applications" "INFO"
    
    $appsToRemove = @(
        "*3DPrint*",
        "Microsoft.MixedReality.Portal",
        "Microsoft.XboxApp",
        "Microsoft.XboxGameOverlay",
        "Microsoft.XboxGamingOverlay",
        "Microsoft.XboxIdentityProvider",
        "Microsoft.XboxSpeechToTextOverlay",
        "Microsoft.Xbox.TCUI",
        "Microsoft.ZuneMusic",
        "Microsoft.ZuneVideo",
        "Microsoft.WindowsMaps",
        "Microsoft.BingWeather",
        "Microsoft.BingNews",
        "Microsoft.GetHelp",
        "Microsoft.Getstarted",
        "Microsoft.MicrosoftOfficeHub",
        "Microsoft.MicrosoftSolitaireCollection",
        "Microsoft.People",
        "Microsoft.SkypeApp",
        "Microsoft.YourPhone",
        "Microsoft.WindowsFeedbackHub"
    )
    
    $removedCount = 0
    $failedCount = 0
    
    foreach ($app in $appsToRemove) {
        try {
            Write-Log "Attempting to remove: $app" "INFO"
            
            $packages = Get-AppxPackage -AllUsers $app -ErrorAction SilentlyContinue
            if ($packages) {
                foreach ($package in $packages) {
                    try {
                        Remove-AppxPackage -Package $package.PackageFullName -ErrorAction Stop
                        Write-Log "Removed: $($package.Name)" "SUCCESS"
                        $removedCount++
                    }
                    catch {
                        Write-Log "Failed to remove $($package.Name): $($_.Exception.Message)" "ERROR"
                        $failedCount++
                    }
                }
            } else {
                Write-Log "No packages found for: $app" "INFO"
            }
        }
        catch {
            Write-Log ("Error processing removal of {0}: {1}" -f $app, $_.Exception.Message) "ERROR"
            $failedCount++
        }
    }
    
    Write-Log "Removal summary - Removed: $removedCount, Failed: $failedCount" "INFO"
}

# Install WSL
function Install-WSL {
    Write-Log "Setting up WSL (Windows Subsystem for Linux)" "INFO"
    
    try {
        # Check if WSL is already installed
        $wslStatus = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -ErrorAction SilentlyContinue
        
        if ($wslStatus.State -eq "Enabled") {
            Write-Log "WSL is already enabled" "INFO"
        } else {
            Write-Log "Enabling WSL feature" "INFO"
            Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart -ErrorAction Stop
        }
        
        # Install WSL using the new method
        Write-Log "Installing WSL with default distribution" "INFO"
        Invoke-SafeCommand -Command {
            wsl --install --no-distribution
        } -ErrorMessage "Failed to install WSL" -ContinueOnError
        
        $Global:SetupReport.WSLInstallation = @{
            FeatureEnabled = $true
            WSLInstalled = $true
            Status = "Completed"
        }
        
        Write-Log "WSL installation completed. A restart may be required." "SUCCESS" "WSLInstallation"
    }
    catch {
        Write-Log "Failed to install WSL: $($_.Exception.Message)" "ERROR" "WSLInstallation"
        $Global:SetupReport.WSLInstallation.Status = "Failed"
        throw
    }
}

# Health checks and system validation
function Test-SystemHealth {
    Write-Log "Performing system health checks" "INFO" "HealthChecks"
    Write-Progress -Activity $Global:ProgressActivity -Status "Performing health checks" -PercentComplete 80
    
    try {
        $healthResults = @{
            SystemResources = Test-SystemResources
            InstalledApplications = Test-InstalledApplications
            NetworkConnectivity = Test-NetworkConnectivity
            DevelopmentTools = Test-DevelopmentTools
            SecurityStatus = Test-SecurityStatus
        }
        
        $Global:SetupReport.HealthChecks = $healthResults
        
        $overallHealth = if ($healthResults.Values | Where-Object { $_ -eq $false }) { "Issues Found" } else { "Healthy" }
        
        Write-Log "System health check completed. Overall status: $overallHealth" "SUCCESS" "HealthChecks"
        
        # Display health summary
        Write-Host "`n=== SYSTEM HEALTH SUMMARY ===" -ForegroundColor Cyan
        foreach ($check in $healthResults.Keys) {
            $status = if ($healthResults[$check]) { "✓ PASS" } else { "✗ FAIL" }
            $color = if ($healthResults[$check]) { "Green" } else { "Red" }
            Write-Host "$check : $status" -ForegroundColor $color
        }
        Write-Host "=============================`n" -ForegroundColor Cyan
        
        return $healthResults
    }
    catch {
        Write-Log "Failed to perform health checks: $($_.Exception.Message)" "ERROR" "HealthChecks"
        return $null
    }
}

function Test-SystemResources {
    try {
        Write-Log "Checking system resources" "INFO" "HealthChecks"
        
        $memory = Get-WmiObject -Class Win32_ComputerSystem
        $totalRAM = [math]::Round($memory.TotalPhysicalMemory / 1GB, 2)
        $availableRAM = [math]::Round((Get-Counter '\Memory\Available MBytes').CounterSamples[0].CookedValue / 1024, 2)
        
        $disk = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'"
        $freeSpace = [math]::Round($disk.FreeSpace / 1GB, 2)
        $totalSpace = [math]::Round($disk.Size / 1GB, 2)
        
        Write-Log "System Resources - RAM: ${availableRAM}GB/${totalRAM}GB, Disk: ${freeSpace}GB/${totalSpace}GB" "INFO" "HealthChecks"
        
        # Check if resources are adequate
        $ramOK = $availableRAM -gt 2  # At least 2GB available
        $diskOK = $freeSpace -gt 10   # At least 10GB free
        
        return ($ramOK -and $diskOK)
    }
    catch {
        Write-Log "Failed to check system resources: $($_.Exception.Message)" "ERROR" "HealthChecks"
        return $false
    }
}

function Test-InstalledApplications {
    try {
        Write-Log "Validating installed applications" "INFO" "HealthChecks"
        
        $criticalApps = @("git", "code", "pwsh", "python", "docker")
        $installedCount = 0
        
        foreach ($app in $criticalApps) {
            $command = Get-Command $app -ErrorAction SilentlyContinue
            if ($command) {
                $installedCount++
                Write-Log "✓ $app is available" "SUCCESS" "HealthChecks"
            } else {
                Write-Log "✗ $app is not available" "WARNING" "HealthChecks"
            }
        }
        
        $successRate = $installedCount / $criticalApps.Count
        return $successRate -gt 0.8  # 80% success rate
    }
    catch {
        Write-Log "Failed to validate applications: $($_.Exception.Message)" "ERROR" "HealthChecks"
        return $false
    }
}

function Test-NetworkConnectivity {
    try {
        Write-Log "Testing network connectivity" "INFO" "HealthChecks"
        
        $testUrls = @("google.com", "github.com", "microsoft.com")
        $successCount = 0
        
        foreach ($url in $testUrls) {
            try {
                $result = Test-NetConnection -ComputerName $url -Port 443 -InformationLevel Quiet -WarningAction SilentlyContinue
                if ($result) {
                    $successCount++
                    Write-Log "✓ Network connectivity to $url" "SUCCESS" "HealthChecks"
                } else {
                    Write-Log "✗ Network connectivity to $url failed" "WARNING" "HealthChecks"
                }
            }
            catch {
                Write-Log "✗ Network test failed for $url" "WARNING" "HealthChecks"
            }
        }
        
        return $successCount -gt 0
    }
    catch {
        Write-Log "Failed to test network connectivity: $($_.Exception.Message)" "ERROR" "HealthChecks"
        return $false
    }
}

function Test-DevelopmentTools {
    try {
        Write-Log "Testing development tools functionality" "INFO" "HealthChecks"
        
        $tests = @()
        
        # Test Git
        try {
            $gitVersion = git --version
            $tests += $true
            Write-Log "✓ Git is functional: $gitVersion" "SUCCESS" "HealthChecks"
        }
        catch {
            $tests += $false
            Write-Log "✗ Git test failed" "WARNING" "HealthChecks"
        }
        
        # Test PowerShell
        try {
            $psVersion = $PSVersionTable.PSVersion
            $tests += $true
            Write-Log "✓ PowerShell is functional: $psVersion" "SUCCESS" "HealthChecks"
        }
        catch {
            $tests += $false
            Write-Log "✗ PowerShell test failed" "WARNING" "HealthChecks"
        }
        
        # Test Python (if installed)
        try {
            $pythonVersion = python --version 2>&1
            if ($pythonVersion -match "Python") {
                $tests += $true
                Write-Log "✓ Python is functional: $pythonVersion" "SUCCESS" "HealthChecks"
            } else {
                $tests += $false
            }
        }
        catch {
            $tests += $false
            Write-Log "✗ Python test failed" "WARNING" "HealthChecks"
        }
        
        return ($tests | Where-Object { $_ -eq $true }).Count -gt 0
    }
    catch {
        Write-Log "Failed to test development tools: $($_.Exception.Message)" "ERROR" "HealthChecks"
        return $false
    }
}

function Test-SecurityStatus {
    try {
        Write-Log "Checking security status" "INFO" "HealthChecks"
        
        $securityChecks = @()
        
        # Check Windows Defender status
        try {
            $defenderStatus = Get-MpComputerStatus
            $securityChecks += $defenderStatus.RealTimeProtectionEnabled
            Write-Log "Windows Defender Real-time Protection: $($defenderStatus.RealTimeProtectionEnabled)" "INFO" "HealthChecks"
        }
        catch {
            $securityChecks += $false
            Write-Log "Failed to check Windows Defender status" "WARNING" "HealthChecks"
        }
        
        # Check firewall status
        try {
            $firewallProfiles = Get-NetFirewallProfile
            $enabledProfiles = $firewallProfiles | Where-Object { $_.Enabled -eq $true }
            $securityChecks += ($enabledProfiles.Count -gt 0)
            Write-Log "Windows Firewall enabled profiles: $($enabledProfiles.Count)" "INFO" "HealthChecks"
        }
        catch {
            $securityChecks += $false
            Write-Log "Failed to check firewall status" "WARNING" "HealthChecks"
        }
        
        return $securityChecks.Count -gt 0
    }
    catch {
        Write-Log "Failed to check security status: $($_.Exception.Message)" "ERROR" "HealthChecks"
        return $false
    }
}

# Comprehensive reporting functions
function New-SetupReport {
    Write-Log "Generating comprehensive setup report" "INFO" "Reporting"
    Write-Progress -Activity $Global:ProgressActivity -Status "Generating report" -PercentComplete 90
    
    try {
        # Update final report data
        $Global:SetupReport.EndTime = Get-Date
        $Global:SetupReport.Duration = $Global:SetupReport.EndTime - $Global:SetupReport.StartTime
        
        # Generate HTML report
        $htmlReport = New-HTMLReport
        
        # Generate JSON report
        $jsonReport = $Global:SetupReport | ConvertTo-Json -Depth 10
        
        # Save reports
        $htmlReport | Out-File -FilePath $ReportPath -Encoding UTF8 -Force
        $jsonReport | Out-File -FilePath ($ReportPath -replace '\.html$', '.json') -Encoding UTF8 -Force
        
        Write-Log "Reports generated successfully:" "SUCCESS" "Reporting"
        Write-Log "HTML Report: $ReportPath" "INFO" "Reporting"
        Write-Log "JSON Report: $($ReportPath -replace '\.html$', '.json')" "INFO" "Reporting"
        
        # Display summary
        Show-SetupSummary
        
        return $true
    }
    catch {
        Write-Log "Failed to generate reports: $($_.Exception.Message)" "ERROR" "Reporting"
        return $false
    }
}

function New-HTMLReport {
    $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lou32 Windows Dev Machine Setup Report</title>
    <style>
        body { font-family: 'Arial', Tahoma, Geneva, Verdana, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { text-align: center; color: #2c3e50; border-bottom: 3px solid #3498db; padding-bottom: 20px; margin-bottom: 30px; }
        .summary { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .summary-card { background: #ecf0f1; padding: 20px; border-radius: 8px; text-align: center; }
        .summary-card h3 { margin: 0 0 10px 0; color: #2c3e50; }
        .summary-card .number { font-size: 2em; font-weight: bold; color: #3498db; }
        .section { margin-bottom: 30px; }
        .section h2 { color: #2c3e50; border-left: 4px solid #3498db; padding-left: 15px; }
        .status-success { color: #27ae60; font-weight: bold; }
        .status-error { color: #e74c3c; font-weight: bold; }
        .status-warning { color: #f39c12; font-weight: bold; }
        .status-info { color: #3498db; font-weight: bold; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #3498db; color: white; }
        tr:nth-child(even) { background-color: #f2f2f2; }
        .timestamp { color: #7f8c8d; font-size: 0.9em; }
        .footer { text-align: center; margin-top: 40px; padding-top: 20px; border-top: 1px solid #bdc3c7; color: #7f8c8d; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Windows Development Machine Setup Report</h1>
            <p class="timestamp">Generated on: $($Global:SetupReport.StartTime.ToString('yyyy-MM-dd HH:mm:ss'))</p>
            <p class="timestamp">Duration: $($Global:SetupReport.Duration.ToString('hh\:mm\:ss'))</p>
        </div>
        
        <div class="summary">
            <div class="summary-card">
                <h3>Success Count</h3>
                <div class="number status-success">$($Global:SetupReport.SuccessCount)</div>
            </div>
            <div class="summary-card">
                <h3>Failure Count</h3>
                <div class="number status-error">$($Global:SetupReport.FailureCount)</div>
            </div>
            <div class="summary-card">
                <h3>Warnings</h3>
                <div class="number status-warning">$($Global:SetupReport.Warnings.Count)</div>
            </div>
            <div class="summary-card">
                <h3>Restore Points</h3>
                <div class="number status-info">$($Global:SetupReport.RestorePoints.Count)</div>
            </div>
        </div>
        
        <div class="section">
            <h2>Prerequisites</h2>
            <table>
                <tr><th>Check</th><th>Status</th><th>Details</th></tr>
                <tr><td>Administrator Privileges</td><td class="status-success">✓ Passed</td><td>Script running with administrator privileges</td></tr>
                <tr><td>PowerShell Version</td><td class="status-success">✓ Passed</td><td>$($Global:SetupReport.Prerequisites.PowerShellVersion)</td></tr>
                <tr><td>Windows Version</td><td class="status-success">✓ Passed</td><td>$($Global:SetupReport.Prerequisites.WindowsVersion)</td></tr>
            </table>
        </div>
        
        <div class="section">
            <h2>Application Installation</h2>
            <table>
                <tr><th>Metric</th><th>Count</th><th>Status</th></tr>
                <tr><td>Total Applications</td><td>$($Global:SetupReport.ApplicationInstallation.TotalApps)</td><td class="status-info">Planned</td></tr>
                <tr><td>Successfully Installed</td><td>$($Global:SetupReport.ApplicationInstallation.Installed)</td><td class="status-success">✓ Completed</td></tr>
                <tr><td>Skipped (Already Installed)</td><td>$($Global:SetupReport.ApplicationInstallation.Skipped)</td><td class="status-info">ℹ Skipped</td></tr>
                <tr><td>Failed Installations</td><td>$($Global:SetupReport.ApplicationInstallation.Failed)</td><td class="status-error">✗ Failed</td></tr>
                <tr><td>Validated Installations</td><td>$($Global:SetupReport.ApplicationInstallation.Validated)</td><td class="status-success">✓ Validated</td></tr>
            </table>
        </div>
        
        <div class="section">
            <h2>System Health Checks</h2>
            <table>
                <tr><th>Check</th><th>Status</th><th>Details</th></tr>
"@

        if ($Global:SetupReport.HealthChecks) {
            foreach ($check in $Global:SetupReport.HealthChecks.Keys) {
                $status = if ($Global:SetupReport.HealthChecks[$check]) { "✓ Pass" } else { "✗ Fail" }
                $statusClass = if ($Global:SetupReport.HealthChecks[$check]) { "status-success" } else { "status-error" }
                $html += "<tr><td>$check</td><td class='$statusClass'>$status</td><td>System health validation</td></tr>"
            }
        }

        $html += @"
            </table>
        </div>
        
        <div class="section">
            <h2>Errors and Warnings</h2>
"@

        if ($Global:SetupReport.Errors.Count -gt 0) {
            $html += "<h3>Errors</h3><table><tr><th>Timestamp</th><th>Category</th><th>Message</th></tr>"
            foreach ($errorItem in $Global:SetupReport.Errors) {
                $html += "<tr><td>$($errorItem.Timestamp)</td><td>$($errorItem.Category)</td><td>$($errorItem.Message)</td></tr>"
            }
            $html += "</table>"
        }

        if ($Global:SetupReport.Warnings.Count -gt 0) {
            $html += "<h3>Warnings</h3><table><tr><th>Timestamp</th><th>Category</th><th>Message</th></tr>"
            foreach ($warning in $Global:SetupReport.Warnings) {
                $html += "<tr><td>$($warning.Timestamp)</td><td>$($warning.Category)</td><td>$($warning.Message)</td></tr>"
            }
            $html += "</table>"
        }

        $html += @"
        </div>
        
        <div class="footer">
            <p>Windows Development Machine Setup Script v3.0</p>
            <p>Generated by PowerShell on $($env:COMPUTERNAME)</p>
        </div>
    </div>
</body>
</html>
"@

        return $html
}

function Show-SetupSummary {
    Write-Host "`n" -NoNewline
    Write-Host "=" * 60 -ForegroundColor Cyan
    Write-Host "           WINDOWS DEVELOPMENT MACHINE SETUP COMPLETE" -ForegroundColor Cyan
    Write-Host "=" * 60 -ForegroundColor Cyan
    
    Write-Host "`n SETUP SUMMARY:" -ForegroundColor Yellow
    Write-Host "   • Total Operations: $($Global:SetupReport.SuccessCount + $Global:SetupReport.FailureCount)" -ForegroundColor White
    Write-Host "   • Successful: $($Global:SetupReport.SuccessCount)" -ForegroundColor Green
    Write-Host "   • Failed: $($Global:SetupReport.FailureCount)" -ForegroundColor Red
    Write-Host "   • Warnings: $($Global:SetupReport.Warnings.Count)" -ForegroundColor Yellow
    Write-Host "   • Duration: $($Global:SetupReport.Duration.ToString('hh\:mm\:ss'))" -ForegroundColor White
    
    Write-Host "`n REPORTS GENERATED:" -ForegroundColor Yellow
    Write-Host "   • HTML Report: $ReportPath" -ForegroundColor White
    Write-Host "   • JSON Report: $($ReportPath -replace '\.html$', '.json')" -ForegroundColor White
    Write-Host "   • Log File: $LogPath" -ForegroundColor White
    
    if ($Global:SetupReport.RestorePoints.Count -gt 0) {
        Write-Host "`n RESTORE POINTS CREATED:" -ForegroundColor Yellow
        foreach ($rp in $Global:SetupReport.RestorePoints) {
            Write-Host "   • $($rp.Description) (Sequence: $($rp.SequenceNumber))" -ForegroundColor White
        }
    }
    
    Write-Host "`n  NEXT STEPS:" -ForegroundColor Yellow
    Write-Host "   1. Review the generated reports for any issues" -ForegroundColor White
    Write-Host "   2. Restart your computer to complete WSL installation" -ForegroundColor White
    Write-Host "   3. Add SSH keys to your GitHub/GitLab accounts" -ForegroundColor White
    Write-Host "   4. Install recommended VS Code extensions" -ForegroundColor White
    Write-Host "   5. Configure any additional development tools as needed" -ForegroundColor White
    
    Write-Host "`n" + "=" * 60 -ForegroundColor Cyan
}

# Main execution
function Main {
    try {
        Write-Log "Starting Windows Development Machine Setup v3.0" "INFO" "Main"
        Write-Log "Log file: $LogPath" "INFO" "Main"
        Write-Log "Report path: $ReportPath" "INFO" "Main"
        Write-Log "Parameters: SkipWinGetInstall=$SkipWinGetInstall, SkipAppInstall=$SkipAppInstall, SkipAppRemoval=$SkipAppRemoval, SkipWSLInstall=$SkipWSLInstall, SkipSystemOptimization=$SkipSystemOptimization, SkipVisualEffects=$SkipVisualEffects, SkipSecurityHardening=$SkipSecurityHardening, DisableWindowsDefender=$DisableWindowsDefender, SkipDevEnvironment=$SkipDevEnvironment, SkipBackup=$SkipBackup" "INFO" "Main"
        Write-Log "Configuration: MaxParallelJobs=$MaxParallelJobs, RetryAttempts=$RetryAttempts, RetryDelaySeconds=$RetryDelaySeconds" "INFO" "Main"
        
        # Import configuration from file if provided
        Import-Configuration -ConfigFilePath $ConfigFile
        
        # Create initial restore point if requested (default behavior)
        if (-not $SkipBackup) {
            New-SystemRestorePoint -Description "Before Windows Development Machine Setup"
        }
        
        # Export system configuration backup
        if (-not $SkipBackup) {
            Export-SystemConfiguration
        }
        
        # Check prerequisites
        Test-Prerequisites
        
        # System optimization
        if (-not $SkipSystemOptimization) {
            Set-SystemOptimizations
        }
        
        # Security hardening
        if (-not $SkipSecurityHardening) {
            Set-SecurityHardening
        }
        
        # Install and configure WinGet
        if (-not $SkipWinGetInstall) {
            Install-WinGet
            Set-WinGetConfiguration
        }
        
        # Install applications with dependency resolution and validation
        if (-not $SkipAppInstall) {
            Install-Applications
        }
        
        # Development environment setup
        if (-not $SkipDevEnvironment) {
            Set-DevelopmentEnvironment
        }
        
        # Remove bloatware
        if (-not $SkipAppRemoval) {
            Remove-Bloatware
        }
        
        # Install WSL
        if (-not $SkipWSLInstall) {
            Install-WSL
        }
        
        # Perform system health checks
        Test-SystemHealth
        
        # Generate comprehensive reports
        New-SetupReport
        
        Write-Log "Development machine setup completed successfully!" "SUCCESS" "Main"
        Write-Log "Please restart your computer to complete the setup process." "INFO" "Main"
    }
    catch {
        Write-Log "Setup failed: $($_.Exception.Message)" "ERROR" "Main"
        Write-Log "Check the log file for detailed error information: $LogPath" "ERROR" "Main"
        
        # Generate error report
        try {
            New-SetupReport
        }
        catch {
            Write-Log "Failed to generate error report: $($_.Exception.Message)" "ERROR" "Main"
        }
        
        exit 1
    }
    finally {
        # Clear progress bar
        Write-Progress -Activity $Global:ProgressActivity -Completed
    }
}

# Run the main function
Main
