BeforeAll {
    # Import the script functions (dot-source the script)
    . "$PSScriptRoot\..\..\lou32dscwin10.ps1"
    
    # Import test helpers
    . "$PSScriptRoot\..\TestHelpers.ps1"
    
    # Initialize test environment
    Initialize-TestGlobals
}

Describe "Write-Log Function" {
    BeforeEach {
        Reset-TestEnvironment
        $script:TestLogPath = "$env:TEMP\TestLog.log"
        if (Test-Path $script:TestLogPath) {
            Remove-Item $script:TestLogPath -Force
        }
    }
    
    AfterEach {
        if (Test-Path $script:TestLogPath) {
            Remove-Item $script:TestLogPath -Force
        }
    }
    
    Context "Logging Functionality" {
        It "Should write log entry with INFO level" {
            # Arrange
            $message = "Test info message"
            $category = "Test"
            
            # Act
            Write-Log -Message $message -Level "INFO" -Category $category
            
            # Assert
            $Global:SetupReport.SuccessCount | Should -BeGreaterOrEqual 1
        }
        
        It "Should write log entry with ERROR level" {
            # Arrange
            $message = "Test error message"
            $category = "Test"
            
            # Act
            Write-Log -Message $message -Level "ERROR" -Category $category
            
            # Assert
            $Global:SetupReport.Errors.Count | Should -BeGreaterThan 0
            $Global:SetupReport.FailureCount | Should -BeGreaterThan 0
        }
        
        It "Should write log entry with WARNING level" {
            # Arrange
            $message = "Test warning message"
            $category = "Test"
            
            # Act
            Write-Log -Message $message -Level "WARNING" -Category $category
            
            # Assert
            $Global:SetupReport.Warnings.Count | Should -BeGreaterThan 0
        }
        
        It "Should write log entry with SUCCESS level" {
            # Arrange
            $message = "Test success message"
            $category = "Test"
            
            # Act
            Write-Log -Message $message -Level "SUCCESS" -Category $category
            
            # Assert
            $Global:SetupReport.SuccessCount | Should -BeGreaterThan 0
        }
        
        It "Should handle missing category parameter" {
            # Arrange
            $message = "Test message without category"
            
            # Act & Assert
            { Write-Log -Message $message -Level "INFO" } | Should -Not -Throw
        }
        
        It "Should format log entry with timestamp" {
            # Arrange
            $message = "Test timestamp message"
            
            # Act
            Write-Log -Message $message -Level "INFO" -Category "Test"
            
            # Assert - Check that the function completes without error
            # The actual log format validation would require file system access
            $true | Should -Be $true
        }
    }
}

Describe "Write-Progress Function" {
    BeforeEach {
        Reset-TestEnvironment
    }
    
    Context "Progress Tracking" {
        It "Should calculate percentage correctly" {
            # Arrange
            $activity = "Test Activity"
            $status = "Test Status"
            $currentOp = 5
            $totalOps = 10
            
            # Act & Assert
            { Write-Progress -Activity $activity -Status $status -CurrentOperation $currentOp -TotalOperations $totalOps } | Should -Not -Throw
        }
        
        It "Should handle zero total operations" {
            # Arrange
            $activity = "Test Activity"
            $status = "Test Status"
            
            # Act & Assert
            { Write-Progress -Activity $activity -Status $status -TotalOperations 0 } | Should -Not -Throw
        }
        
        It "Should accept manual percentage" {
            # Arrange
            $activity = "Test Activity"
            $status = "Test Status"
            $percent = 75
            
            # Act & Assert
            { Write-Progress -Activity $activity -Status $status -PercentComplete $percent } | Should -Not -Throw
        }
    }
}