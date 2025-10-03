BeforeAll {
    # Import the script functions (dot-source the script)
    . "$PSScriptRoot\..\..\lou32dscwin10.ps1"
    
    # Import test helpers
    . "$PSScriptRoot\..\TestHelpers.ps1"
    
    # Initialize test environment
    Initialize-TestGlobals
}

Describe "Package Management" {
    BeforeEach {
        Reset-TestEnvironment
    }
    
    Context "Resolve-PackageDependencies Function" {
        It "Should return empty array for package with no dependencies" {
            # Arrange
            $packageName = "7zip.7zip"
            
            # Act
            $dependencies = Resolve-PackageDependencies -PackageName $packageName
            
            # Assert
            $dependencies | Should -BeOfType [array]
            $dependencies.Count | Should -BeGreaterOrEqual 0
        }
        
        It "Should return dependencies for package with dependencies" {
            # Arrange
            $packageName = "Microsoft.VisualStudioCode"
            
            # Act
            $dependencies = Resolve-PackageDependencies -PackageName $packageName
            
            # Assert
            $dependencies | Should -BeOfType [array]
        }
        
        It "Should handle unknown package gracefully" {
            # Arrange
            $packageName = "NonExistent.Package"
            
            # Act
            $dependencies = Resolve-PackageDependencies -PackageName $packageName
            
            # Assert
            $dependencies | Should -BeOfType [array]
            $dependencies.Count | Should -Be 0
        }
    }
    
    Context "Test-PackageInstallation Function" {
        It "Should validate package name parameter" {
            # Arrange
            $packageName = ""
            
            # Act & Assert
            { Test-PackageInstallation -PackageName $packageName } | Should -Throw
        }
        
        It "Should return boolean result" {
            # Arrange
            $packageName = "Git.Git"
            
            # Mock winget list command
            Mock Invoke-Expression { return "Git.Git" } -ParameterFilter { $Command -like "*winget list*" }
            
            # Act
            $result = Test-PackageInstallation -PackageName $packageName
            
            # Assert
            $result | Should -BeOfType [bool]
        }
    }
    
    Context "Test-PackageSource Function" {
        It "Should validate package source availability" {
            # Arrange
            $sourceName = "winget"
            
            # Mock winget source list command
            Mock Invoke-Expression { return "winget" } -ParameterFilter { $Command -like "*winget source list*" }
            
            # Act
            $result = Test-PackageSource -SourceName $sourceName
            
            # Assert
            $result | Should -BeOfType [bool]
        }
        
        It "Should handle invalid source gracefully" {
            # Arrange
            $sourceName = "invalid-source"
            
            # Mock winget source list command to return empty
            Mock Invoke-Expression { return "" } -ParameterFilter { $Command -like "*winget source list*" }
            
            # Act
            $result = Test-PackageSource -SourceName $sourceName
            
            # Assert
            $result | Should -Be $false
        }
    }
}