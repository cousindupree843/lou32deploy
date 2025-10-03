# Test Runner Script for Lou32Deploy
# Run this script to execute all tests with proper Pester 5 syntax

param(
    [string]$TestPath = "./tests",
    [string]$OutputPath = "./TestResults.xml",
    [switch]$EnableCodeCoverage,
    [string]$Verbosity = "Normal"
)

# Ensure Pester is available
if (-not (Get-Module -ListAvailable -Name Pester)) {
    Write-Warning "Pester module not found. Installing Pester..."
    Install-Module -Name Pester -Force -SkipPublisherCheck -Scope CurrentUser
}

# Import Pester
Import-Module Pester -Force

# Create Pester configuration
$config = New-PesterConfiguration

# Set basic configuration
$config.Run.Path = $TestPath
$config.Run.PassThru = $true
$config.Output.Verbosity = $Verbosity

# Configure test results
$config.TestResult.Enabled = $true
$config.TestResult.OutputFormat = 'NUnitXml'
$config.TestResult.OutputPath = $OutputPath

# Configure code coverage if requested
if ($EnableCodeCoverage) {
    $config.CodeCoverage.Enabled = $true
    $config.CodeCoverage.Path = './lou32dscwin10.ps1'
    $config.CodeCoverage.OutputPath = './coverage.xml'
}

# Run tests
Write-Host "Running Lou32Deploy tests..." -ForegroundColor Green
Write-Host "Test Path: $TestPath" -ForegroundColor Cyan
Write-Host "Output Path: $OutputPath" -ForegroundColor Cyan

$result = Invoke-Pester -Configuration $config

# Display results
Write-Host "`nTest Results:" -ForegroundColor Yellow
Write-Host "Total Tests: $($result.TotalCount)" -ForegroundColor White
Write-Host "Passed: $($result.PassedCount)" -ForegroundColor Green
Write-Host "Failed: $($result.FailedCount)" -ForegroundColor Red
Write-Host "Skipped: $($result.SkippedCount)" -ForegroundColor Yellow

if ($result.FailedCount -gt 0) {
    Write-Host "`nFailed Tests:" -ForegroundColor Red
    $result.Failed | ForEach-Object {
        Write-Host "  - $($_.Name)" -ForegroundColor Red
    }
    exit 1
} else {
    Write-Host "`nAll tests passed!" -ForegroundColor Green
    exit 0
}