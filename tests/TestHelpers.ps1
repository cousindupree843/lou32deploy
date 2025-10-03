# Test Helpers for Lou32Deploy Tests
# Common functions and utilities for testing

# Mock data and test configuration
$script:TestConfig = @{
    TestApplications = @(
        @{name="Git.Git"; category="Development"},
        @{name="Microsoft.VisualStudioCode"; category="Development"},
        @{name="7zip.7zip"; category="Utilities"}
    )
    TestUser = @{
        Name = "TestUser"
        Email = "test@example.com"
    }
    TestPaths = @{
        TempLog = "$env:TEMP\TestDevMachineSetup.log"
        TempReport = "$env:TEMP\TestDevMachineSetup_Report.html"
        TempConfig = "$env:TEMP\TestConfiguration.json"
    }
}

# Helper function to create test configuration
function New-TestConfiguration {
    param(
        [string]$Path = $script:TestConfig.TestPaths.TempConfig
    )
    
    $config = @{
        Applications = $script:TestConfig.TestApplications
        NetworkOptimizations = @{
            EnableDeliveryOptimization = $true
            EnableTCPOptimizations = $true
        }
        PackageManagement = @{
            EnableParallelInstallation = $false
            MaxParallelJobs = 2
            RetryAttempts = 2
        }
    }
    
    $config | ConvertTo-Json -Depth 10 | Out-File -FilePath $Path -Encoding UTF8
    return $Path
}

# Helper function to clean up test files
function Remove-TestFiles {
    $script:TestConfig.TestPaths.Values | ForEach-Object {
        if (Test-Path $_) {
            Remove-Item $_ -Force -ErrorAction SilentlyContinue
        }
    }
}

# Helper function to mock Windows version
function Set-MockWindowsVersion {
    param(
        [string]$Version = "10.0.19045"
    )
    
    Mock Get-CimInstance {
        return @{
            BuildNumber = $Version.Split('.')[2]
            Caption = "Microsoft Windows 10 Pro"
        }
    } -ParameterFilter { $ClassName -eq "Win32_OperatingSystem" }
}

# Helper function to mock administrator check
function Set-MockAdministratorCheck {
    param(
        [bool]$IsAdmin = $true
    )
    
    Mock Test-Path { return $IsAdmin } -ParameterFilter { $Path -eq "HKLM:" }
}

# Helper function to mock PowerShell version
function Set-MockPowerShellVersion {
    param(
        [version]$Version = "5.1.19041.1320"
    )
    
    $global:PSVersionTable = @{
        PSVersion = $Version
    }
}

# Helper function to initialize test globals
function Initialize-TestGlobals {
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
    
    $Global:Configuration = @{
        Applications = @()
        NetworkOptimizations = @{
            EnableDeliveryOptimization = $true
            EnableTCPOptimizations = $true
        }
        PackageManagement = @{
            EnableParallelInstallation = $true
            MaxParallelJobs = 4
            RetryAttempts = 3
            RetryDelaySeconds = 5
        }
        SystemOptimizations = @{
            EnableVisualEffectsDisable = $true
            EnablePowerPlanOptimization = $true
            EnableNetworkOptimization = $true
        }
    }
    
    $Global:ProgressActivity = "Test Windows Development Machine Setup"
    $Global:ProgressId = 1
}

# Helper function to reset test environment
function Reset-TestEnvironment {
    Remove-TestFiles
    Initialize-TestGlobals
}

# Export functions for use in tests
Export-ModuleMember -Function @(
    'New-TestConfiguration',
    'Remove-TestFiles', 
    'Set-MockWindowsVersion',
    'Set-MockAdministratorCheck',
    'Set-MockPowerShellVersion',
    'Initialize-TestGlobals',
    'Reset-TestEnvironment'
) -Variable @('TestConfig')