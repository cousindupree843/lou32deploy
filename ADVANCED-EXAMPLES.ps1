# Lou32 Deployment Protocol - Advanced Configuration Example
#
# This file demonstrates advanced customization options for the deployment script.
# Copy and modify sections as needed for your specific requirements.

# ============================================================================
# CUSTOM APPLICATION INSTALLATION EXAMPLE
# ============================================================================

<#
To add custom applications, modify the $applications array in Setup-DevMachine.ps1:

function Install-Applications {
    Start-Section "INSTALLING APPLICATIONS VIA WINGET"
    
    $applications = @(
        # Development Tools
        @{Name="Git"; Id="Git.Git"},
        @{Name="Visual Studio Code"; Id="Microsoft.VisualStudioCode"},
        
        # Add your custom apps here:
        @{Name="IntelliJ IDEA"; Id="JetBrains.IntelliJIDEA.Community"},
        @{Name="Rust"; Id="Rustlang.Rust.MSVC"},
        @{Name="Go"; Id="GoLang.Go"},
        
        # Database Tools
        @{Name="PostgreSQL"; Id="PostgreSQL.PostgreSQL"},
        @{Name="MongoDB"; Id="MongoDB.Server"},
        
        # Cloud CLI Tools
        @{Name="Azure CLI"; Id="Microsoft.AzureCLI"},
        @{Name="AWS CLI"; Id="Amazon.AWSCLI"}
    )
    
    foreach ($app in $applications) {
        # Installation logic...
    }
}
#>

# ============================================================================
# CUSTOM REGISTRY TWEAKS EXAMPLE
# ============================================================================

<#
Add custom registry modifications:

function Set-CustomRegistryTweaks {
    Start-Section "APPLYING CUSTOM REGISTRY TWEAKS"
    
    try {
        # Example: Disable Windows Update automatic restart
        Write-Log "Disabling automatic restart after Windows Update..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoRebootWithLoggedOnUsers" -Value 1 -Type DWord -Force
        
        # Example: Disable automatic driver updates
        Write-Log "Disabling automatic driver updates..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" -Name "SearchOrderConfig" -Value 0 -Type DWord -Force
        
        # Example: Set custom page file size
        Write-Log "Configuring page file..."
        # Use WMI to configure page file
        $computersys = Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges
        $computersys.AutomaticManagedPagefile = $false
        $computersys.Put()
        
        # Example: Disable Windows Defender samples submission
        Write-Log "Configuring Windows Defender..."
        Set-MpPreference -SubmitSamplesConsent NeverSend -ErrorAction SilentlyContinue
        
        Write-Log "Custom registry tweaks applied" -Level "SUCCESS"
    }
    catch {
        Write-Log "Error applying custom tweaks: $($_.Exception.Message)" -Level "ERROR"
    }
}

# Call in Main function:
# Set-CustomRegistryTweaks
#>

# ============================================================================
# CUSTOM WINDOWS FEATURES MANAGEMENT
# ============================================================================

<#
Enable or disable Windows features:

function Set-WindowsFeatures {
    Start-Section "CONFIGURING WINDOWS FEATURES"
    
    try {
        # Enable features
        $featuresToEnable = @(
            "Microsoft-Windows-Subsystem-Linux",
            "VirtualMachinePlatform",
            "Containers",
            "Microsoft-Hyper-V-All"
        )
        
        foreach ($feature in $featuresToEnable) {
            Write-Log "Enabling feature: $feature"
            Enable-WindowsOptionalFeature -Online -FeatureName $feature -NoRestart -ErrorAction SilentlyContinue
        }
        
        # Disable features
        $featuresToDisable = @(
            "WorkFolders-Client",
            "Printing-XPSServices-Features",
            "WindowsMediaPlayer"
        )
        
        foreach ($feature in $featuresToDisable) {
            Write-Log "Disabling feature: $feature"
            Disable-WindowsOptionalFeature -Online -FeatureName $feature -NoRestart -ErrorAction SilentlyContinue
        }
        
        Write-Log "Windows features configured" -Level "SUCCESS"
    }
    catch {
        Write-Log "Error configuring Windows features: $($_.Exception.Message)" -Level "ERROR"
    }
}
#>

# ============================================================================
# CUSTOM SCHEDULED TASKS EXAMPLE
# ============================================================================

<#
Create custom scheduled tasks:

function New-CustomScheduledTasks {
    Start-Section "CREATING CUSTOM SCHEDULED TASKS"
    
    try {
        # Example: Daily Windows Update check at 3 AM
        $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -Command `"Install-Module PSWindowsUpdate -Force; Get-WindowsUpdate -Install -AcceptAll -AutoReboot`""
        $trigger = New-ScheduledTaskTrigger -Daily -At 3am
        $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
        
        Register-ScheduledTask -TaskName "AutoWindowsUpdate" -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force
        
        Write-Log "Scheduled tasks created" -Level "SUCCESS"
    }
    catch {
        Write-Log "Error creating scheduled tasks: $($_.Exception.Message)" -Level "ERROR"
    }
}
#>

# ============================================================================
# CUSTOM ENVIRONMENT VARIABLES
# ============================================================================

<#
Set custom environment variables:

function Set-CustomEnvironmentVariables {
    Start-Section "SETTING CUSTOM ENVIRONMENT VARIABLES"
    
    try {
        # User-level variables
        [System.Environment]::SetEnvironmentVariable("DEV_HOME", "C:\Development", "User")
        [System.Environment]::SetEnvironmentVariable("PROJECTS", "C:\Projects", "User")
        
        # System-level variables (requires admin)
        [System.Environment]::SetEnvironmentVariable("COMPANY_TOOLS", "C:\Tools", "Machine")
        
        # Add to PATH
        $currentPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
        $newPath = "C:\CustomTools\bin"
        if ($currentPath -notlike "*$newPath*") {
            [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$newPath", "User")
        }
        
        Write-Log "Environment variables configured" -Level "SUCCESS"
    }
    catch {
        Write-Log "Error setting environment variables: $($_.Exception.Message)" -Level "ERROR"
    }
}
#>

# ============================================================================
# CUSTOM NETWORK CONFIGURATION
# ============================================================================

<#
Configure network settings:

function Set-NetworkConfiguration {
    Start-Section "CONFIGURING NETWORK SETTINGS"
    
    try {
        # Set DNS servers (example: using Google DNS)
        $adapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Select-Object -First 1
        if ($adapter) {
            Write-Log "Configuring DNS for adapter: $($adapter.Name)"
            Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ServerAddresses ("8.8.8.8","8.8.4.4")
        }
        
        # Disable IPv6 (if needed)
        # Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6
        
        # Configure network profile to Private
        Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private
        
        Write-Log "Network configuration completed" -Level "SUCCESS"
    }
    catch {
        Write-Log "Error configuring network: $($_.Exception.Message)" -Level "ERROR"
    }
}
#>

# ============================================================================
# CUSTOM FILE ASSOCIATIONS
# ============================================================================

<#
Set default file associations:

function Set-FileAssociations {
    Start-Section "CONFIGURING FILE ASSOCIATIONS"
    
    try {
        # Example: Set VS Code as default for various file types
        $vscodePath = "C:\Users\$env:USERNAME\AppData\Local\Programs\Microsoft VS Code\Code.exe"
        
        if (Test-Path $vscodePath) {
            $extensions = @(".txt", ".log", ".json", ".xml", ".yml", ".yaml", ".md")
            
            foreach ($ext in $extensions) {
                Write-Log "Setting VS Code as default for $ext files"
                # This requires creating proper file association configurations
                # Use Group Policy or DISM for enterprise deployments
            }
        }
        
        Write-Log "File associations configured" -Level "SUCCESS"
    }
    catch {
        Write-Log "Error setting file associations: $($_.Exception.Message)" -Level "ERROR"
    }
}
#>

# ============================================================================
# CUSTOM DEVELOPER TOOLS CONFIGURATION
# ============================================================================

<#
Configure development tools:

function Initialize-DeveloperTools {
    Start-Section "INITIALIZING DEVELOPER TOOLS"
    
    try {
        # Configure Git
        git config --global core.autocrlf true
        git config --global core.editor "code --wait"
        git config --global init.defaultBranch main
        git config --global pull.rebase false
        
        # Install Node.js global packages
        if (Get-Command npm -ErrorAction SilentlyContinue) {
            Write-Log "Installing global npm packages..."
            npm install -g yarn
            npm install -g typescript
            npm install -g eslint
            npm install -g prettier
        }
        
        # Install Python packages
        if (Get-Command pip -ErrorAction SilentlyContinue) {
            Write-Log "Installing Python packages..."
            pip install --upgrade pip
            pip install virtualenv
            pip install pylint
            pip install black
        }
        
        # Configure PowerShell profile
        $profilePath = $PROFILE.CurrentUserAllHosts
        if (-not (Test-Path $profilePath)) {
            New-Item -Path $profilePath -ItemType File -Force
        }
        
        # Add useful aliases to PowerShell profile
        @"
# Custom aliases
Set-Alias -Name 'g' -Value 'git'
Set-Alias -Name 'c' -Value 'code'
Set-Alias -Name 'll' -Value 'Get-ChildItem'

# Custom functions
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function projects { Set-Location C:\Projects }
"@ | Add-Content -Path $profilePath
        
        Write-Log "Developer tools initialized" -Level "SUCCESS"
    }
    catch {
        Write-Log "Error initializing developer tools: $($_.Exception.Message)" -Level "ERROR"
    }
}
#>

# ============================================================================
# CUSTOM FOLDER STRUCTURE
# ============================================================================

<#
Create custom folder structure:

function New-DevelopmentFolders {
    Start-Section "CREATING DEVELOPMENT FOLDER STRUCTURE"
    
    try {
        $folders = @(
            "C:\Development",
            "C:\Development\Projects",
            "C:\Development\Tools",
            "C:\Development\Workspace",
            "C:\Development\Learning",
            "C:\Projects\Personal",
            "C:\Projects\Work",
            "C:\Tools",
            "C:\Temp"
        )
        
        foreach ($folder in $folders) {
            if (-not (Test-Path $folder)) {
                Write-Log "Creating folder: $folder"
                New-Item -Path $folder -ItemType Directory -Force | Out-Null
            }
        }
        
        Write-Log "Development folder structure created" -Level "SUCCESS"
    }
    catch {
        Write-Log "Error creating folders: $($_.Exception.Message)" -Level "ERROR"
    }
}
#>

# ============================================================================
# USAGE INSTRUCTIONS
# ============================================================================

<#
To use these customizations:

1. Copy the desired function(s) to Setup-DevMachine.ps1
2. Add the function call to the Main function
3. Optionally add a skip parameter for the function
4. Test in a VM before deploying to production

Example integration in Main function:

function Main {
    # ... existing code ...
    
    if (-not $SkipSecurityBaseline) {
        Set-SecurityBaseline
    }
    
    # Add custom functions here
    Set-CustomRegistryTweaks
    Set-WindowsFeatures
    Initialize-DeveloperTools
    New-DevelopmentFolders
    
    # ... rest of the code ...
}

Example with skip parameter:

[CmdletBinding()]
param(
    # ... existing parameters ...
    [switch]$SkipCustomTweaks
)

# In Main function:
if (-not $SkipCustomTweaks) {
    Set-CustomRegistryTweaks
    Set-WindowsFeatures
}
#>
