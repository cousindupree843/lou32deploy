BeforeAll {
    # Import the script functions (dot-source the script)
    . "$PSScriptRoot\..\..\lou32dscwin10.ps1"
    
    # Import test helpers
    . "$PSScriptRoot\..\TestHelpers.ps1"
    
    # Initialize test environment
    Initialize-TestGlobals
}

Describe "Configuration Management" {
    BeforeEach {
        Reset-TestEnvironment
    }
    
    AfterEach {
        Remove-TestFiles
    }
    
    Context "Import-Configuration Function" {
        It "Should handle missing configuration file gracefully" {
            # Arrange
            $nonExistentPath = "C:\NonExistent\config.json"
            
            # Act & Assert
            { Import-Configuration -ConfigFilePath $nonExistentPath } | Should -Not -Throw
        }
        
        It "Should import valid JSON configuration" {
            # Arrange
            $configPath = New-TestConfiguration
            
            # Act
            Import-Configuration -ConfigFilePath $configPath
            
            # Assert
            $Global:Configuration.Applications | Should -HaveCount 3
            $Global:Configuration.Applications[0].name | Should -Be "Git.Git"
        }
        
        It "Should handle invalid JSON gracefully" {
            # Arrange
            $invalidConfigPath = "$env:TEMP\invalid.json"
            "{ invalid json content" | Out-File -FilePath $invalidConfigPath -Encoding UTF8
            
            # Act & Assert
            { Import-Configuration -ConfigFilePath $invalidConfigPath } | Should -Not -Throw
            
            # Cleanup
            Remove-Item $invalidConfigPath -Force -ErrorAction SilentlyContinue
        }
        
        It "Should merge configuration with defaults" {
            # Arrange
            $configPath = New-TestConfiguration
            $originalRetryAttempts = $Global:Configuration.PackageManagement.RetryAttempts
            
            # Act
            Import-Configuration -ConfigFilePath $configPath
            
            # Assert
            $Global:Configuration.PackageManagement.RetryAttempts | Should -Be 2
            $Global:Configuration.NetworkOptimizations.EnableDeliveryOptimization | Should -Be $true
        }
    }
    
    Context "Global Configuration Variables" {
        It "Should initialize Global:Configuration properly" {
            # Assert
            $Global:Configuration | Should -Not -BeNullOrEmpty
            $Global:Configuration.Applications | Should -Not -BeNull
            $Global:Configuration.NetworkOptimizations | Should -Not -BeNull
            $Global:Configuration.PackageManagement | Should -Not -BeNull
            $Global:Configuration.SystemOptimizations | Should -Not -BeNull
        }
        
        It "Should initialize Global:SetupReport properly" {
            # Assert
            $Global:SetupReport | Should -Not -BeNullOrEmpty
            $Global:SetupReport.StartTime | Should -Not -BeNull
            $Global:SetupReport.Errors | Should -BeOfType [System.Collections.ArrayList] -Because "Errors should be a collection"
            $Global:SetupReport.Warnings | Should -BeOfType [System.Collections.ArrayList] -Because "Warnings should be a collection"
        }
    }
}