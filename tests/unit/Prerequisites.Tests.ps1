BeforeAll {
    # Import the script functions (dot-source the script)
    . "$PSScriptRoot\..\..\lou32dscwin10.ps1"
    
    # Import test helpers
    . "$PSScriptRoot\..\TestHelpers.ps1"
    
    # Initialize test environment
    Initialize-TestGlobals
}

Describe "Prerequisites Validation" {
    BeforeEach {
        Reset-TestEnvironment
    }
    
    Context "Test-Prerequisites Function" {
        It "Should pass when all prerequisites are met" {
            # Arrange
            Set-MockWindowsVersion -Version "10.0.19045"
            Set-MockPowerShellVersion -Version "5.1.19041.1320"
            Set-MockAdministratorCheck -IsAdmin $true
            
            # Act & Assert
            { Test-Prerequisites } | Should -Not -Throw
        }
        
        It "Should validate Windows version requirement" {
            # Arrange
            Set-MockWindowsVersion -Version "6.1.7601" # Windows 7
            Set-MockPowerShellVersion -Version "5.1.19041.1320"
            Set-MockAdministratorCheck -IsAdmin $true
            
            # Act & Assert
            # This should log an error but may not throw depending on implementation
            Test-Prerequisites
            $Global:SetupReport.Errors.Count | Should -BeGreaterThan 0
        }
        
        It "Should validate PowerShell version requirement" {
            # Arrange
            Set-MockWindowsVersion -Version "10.0.19045"
            Set-MockPowerShellVersion -Version "4.0" # Below required version
            Set-MockAdministratorCheck -IsAdmin $true
            
            # Act & Assert
            Test-Prerequisites
            $Global:SetupReport.Errors.Count | Should -BeGreaterThan 0
        }
        
        It "Should validate administrator privileges" {
            # Arrange
            Set-MockWindowsVersion -Version "10.0.19045"
            Set-MockPowerShellVersion -Version "5.1.19041.1320"
            Set-MockAdministratorCheck -IsAdmin $false
            
            # Act & Assert
            Test-Prerequisites
            $Global:SetupReport.Errors.Count | Should -BeGreaterThan 0
        }
        
        It "Should update Global:SetupReport.Prerequisites" {
            # Arrange
            Set-MockWindowsVersion -Version "10.0.19045"
            Set-MockPowerShellVersion -Version "5.1.19041.1320"
            Set-MockAdministratorCheck -IsAdmin $true
            
            # Act
            Test-Prerequisites
            
            # Assert
            $Global:SetupReport.Prerequisites | Should -Not -BeNullOrEmpty
            $Global:SetupReport.Prerequisites.WindowsVersion | Should -Not -BeNullOrEmpty
            $Global:SetupReport.Prerequisites.PowerShellVersion | Should -Not -BeNullOrEmpty
            $Global:SetupReport.Prerequisites.IsAdmin | Should -Be $true
        }
    }
}