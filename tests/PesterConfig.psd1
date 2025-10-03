# Pester Configuration for Lou32Deploy Tests
# This file defines test execution settings and configuration

@{
    # Test execution settings
    Run = @{
        Path = @(
            './tests/unit',
            './tests/integration'
        )
        ExcludePath = @()
        ScriptBlock = @()
        Container = @()
        TestExtension = '.Tests.ps1'
        Exit = $false
        Throw = $false
        PassThru = $true
    }
    
    # Output settings
    Output = @{
        Verbosity = 'Normal'
        StackTraceVerbosity = 'Filtered'
        CIFormat = 'Auto'
    }
    
    # Test result settings
    TestResult = @{
        Enabled = $true
        OutputFormat = 'NUnitXml'
        OutputPath = './TestResults.xml'
        OutputEncoding = 'UTF8'
        TestSuiteName = 'Lou32Deploy Tests'
    }
    
    # Code coverage settings (optional)
    CodeCoverage = @{
        Enabled = $false
        Path = @('./lou32dscwin10.ps1')
        OutputFormat = 'JaCoCo'
        OutputPath = './coverage.xml'
        OutputEncoding = 'UTF8'
    }
    
    # Should settings
    Should = @{
        ErrorAction = 'Stop'
    }
    
    # Debug settings
    Debug = @{
        ShowFullErrors = $true
        WriteDebugMessages = $false
        WriteDebugMessagesFrom = @()
        ShowNavigationMarkers = $false
        ReturnRawResultObject = $false
    }
}