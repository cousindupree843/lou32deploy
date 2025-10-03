BeforeAll {
    # Import the script functions (dot-source the script)
    . "$PSScriptRoot\..\..\lou32dscwin10.ps1"
    
    # Import test helpers
    . "$PSScriptRoot\..\TestHelpers.ps1"
    
    # Initialize test environment
    Initialize-TestGlobals
}

Describe "Integration Tests - Full Setup Process" {
    BeforeAll {
        # These tests require more setup and may take longer
        $script:OriginalLocation = Get-Location
    }
    
    AfterAll {
        Set-Location $script:OriginalLocation
        Remove-TestFiles
    }
    
    BeforeEach {
        Reset-TestEnvironment
        
        # Mock external dependencies for integration tests
        Mock Get-CimInstance { 
            return @{ BuildNumber = "19045"; Caption = "Microsoft Windows 10 Pro" } 
        } -ParameterFilter { $ClassName -eq "Win32_OperatingSystem" }
        
        Mock Test-Path { return $true } -ParameterFilter { $Path -eq "HKLM:" }
        
        Mock Invoke-Expression { return "Git.Git" } -ParameterFilter { $Command -like "*winget*" }
    }
    
    Context "Prerequisites and Configuration" {
        It "Should complete prerequisites check successfully" {
            # Act
            { Test-Prerequisites } | Should -Not -Throw
            
            # Assert
            $Global:SetupReport.Prerequisites | Should -Not -BeNullOrEmpty
        }
        
        It "Should load configuration successfully" {
            # Arrange
            $configPath = New-TestConfiguration
            
            # Act
            { Import-Configuration -ConfigFilePath $configPath } | Should -Not -Throw
            
            # Assert
            $Global:Configuration.Applications | Should -HaveCount 3
        }
        
        It "Should initialize global variables correctly" {
            # Assert
            $Global:SetupReport | Should -Not -BeNullOrEmpty
            $Global:Configuration | Should -Not -BeNullOrEmpty
            $Global:ProgressActivity | Should -Not -BeNullOrEmpty
            $Global:ProgressId | Should -BeGreaterThan 0
        }
    }
    
    Context "Logging and Progress Integration" {
        It "Should maintain consistent logging throughout process" {
            # Arrange
            $initialErrorCount = $Global:SetupReport.Errors.Count
            $initialWarningCount = $Global:SetupReport.Warnings.Count
            
            # Act
            Write-Log "Test info message" "INFO" "Integration"
            Write-Log "Test warning message" "WARNING" "Integration"
            Write-Log "Test success message" "SUCCESS" "Integration"
            
            # Assert
            $Global:SetupReport.Warnings.Count | Should -BeGreaterThan $initialWarningCount
            $Global:SetupReport.SuccessCount | Should -BeGreaterThan 0
        }
        
        It "Should handle error accumulation correctly" {
            # Arrange
            $initialErrorCount = $Global:SetupReport.Errors.Count
            
            # Act
            Write-Log "Test error 1" "ERROR" "Integration"
            Write-Log "Test error 2" "ERROR" "Integration"
            
            # Assert
            $Global:SetupReport.Errors.Count | Should -Be ($initialErrorCount + 2)
            $Global:SetupReport.FailureCount | Should -BeGreaterThan 0
        }
    }
    
    Context "Configuration and Package Integration" {
        It "Should resolve dependencies for configured packages" {
            # Arrange
            $configPath = New-TestConfiguration
            Import-Configuration -ConfigFilePath $configPath
            
            # Act
            $dependencies = @()
            foreach ($app in $Global:Configuration.Applications) {
                $deps = Resolve-PackageDependencies -PackageName $app.name
                $dependencies += $deps
            }
            
            # Assert
            $dependencies | Should -BeOfType [array]
        }
        
        It "Should validate package management configuration" {
            # Arrange
            $configPath = New-TestConfiguration
            Import-Configuration -ConfigFilePath $configPath
            
            # Assert
            $Global:Configuration.PackageManagement.MaxParallelJobs | Should -BeGreaterThan 0
            $Global:Configuration.PackageManagement.RetryAttempts | Should -BeGreaterThan 0
        }
    }
}