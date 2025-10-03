# Lou32Deploy - Windows Development Machine Setup

## Project Overview

Lou32Deploy is a comprehensive PowerShell-based automation framework for setting up Windows development environments. The project provides enterprise-grade machine provisioning with dependency resolution, security hardening, system optimization, and comprehensive reporting.

## Core Architecture

### Single-Script Design
- **Primary Script**: `lou32dscwin10.ps1` (3100+ lines) - monolithic setup script containing all functions and logic
- All functions are defined in-line within the main script (no module structure)
- Script must be dot-sourced for testing: `. $PSScriptRoot\..\..\lou32dscwin10.ps1`

### Setup Execution Flow
The `Main` function orchestrates these phases in strict order:
1. Configuration import from JSON (if `-ConfigFile` provided)
2. System restore point creation (unless `-SkipBackup`)
3. Prerequisites check (`Test-Prerequisites`)
4. System optimization (`Set-SystemOptimizations`) - registry tweaks, power plan
5. Security hardening (`Set-SecurityHardening`) - firewall, Defender, updates
6. WinGet installation and configuration
7. Application installation (`Install-Applications`) - with dependency resolution
8. Development environment setup (`Set-DevelopmentEnvironment`) - Git, SSH, VS Code
9. Bloatware removal (`Remove-Bloatware`)
10. WSL installation (`Install-WSL`)
11. Health checks and HTML report generation

### Configuration System
- **JSON Config**: `dev-setup-config.json` (500 lines) defines 100+ packages to install
- **Package Structure**: Each package has `name`, `category`, `executable`, optional `requiresRestart`
- **Global Variables**: 
  - `$Global:Configuration` - merged JSON config with defaults
  - `$Global:SetupReport` - tracks success/failure counts, errors, warnings, timings
  - `$Global:ProgressActivity` and `$Global:ProgressId` - for progress tracking

### Dependency Resolution Pattern
The `Resolve-PackageDependencies` function (lines 350-420) contains a hardcoded dependency map:
- Returns array of package names that must be installed first
- Common pattern: Most packages depend on `Microsoft.VCRedist.2015+.x64`
- Complex chains: `Microsoft.DotNet.SDK.8` → `Microsoft.DotNet.DesktopRuntime.8` → `Microsoft.VCRedist.2015+.x64`
- Called during `Install-Applications` to sort packages topologically

## Critical Development Patterns

### Error Handling & Retry Logic
All functions use consistent patterns:
- `Invoke-SafeCommand` - wrapper for retry with exponential backoff (lines 461-522)
- Default retry: 3 attempts, 5-second initial delay, doubles each retry (max 60-120 seconds)
- WinGet exit codes: `0` = success, `-1978335189` = already installed, `-1978335226` = up to date

### Logging System
`Write-Log` function (lines 192-249) handles all output:
- Levels: INFO (white), WARNING (yellow), ERROR (red), SUCCESS (green)
- Categories: Used to group related operations (e.g., "ApplicationInstallation", "SecurityHardening")
- Automatically updates `$Global:SetupReport.Errors`, `.Warnings`, `.SuccessCount`, `.FailureCount`
- Logs to file at `$LogPath` (default: `$env:TEMP\DevMachineSetup.log`)

### Package Installation Pattern
1. **Validation**: `Test-PackageSource` checks if package exists in WinGet
2. **Installation**: `Install-PackageWithRetry` (lines 1254-1420) handles single package
   - Checks if already installed via `winget list`
   - Uses package-specific WinGet arguments (switch statement at line 1290)
   - Validates installation with `Test-PackageInstallation` if `executable` defined
3. **Parallel Processing**: `Install-PackageParallel` runs up to `$MaxParallelJobs` (default 4) concurrent installations
   - Uses PowerShell background jobs (`Start-Job`, `Get-Job`, `Receive-Job`)
   - Job contains embedded copy of `Install-PackageWithRetry` function (lines 1446-1540)

### Progress Tracking
Custom `Write-Progress` function maintains operation visibility:
- Calculates percentage from current/total operations
- Updates `$Global:ProgressActivity` with phase names
- Must call with `-Completed` in finally block to clear progress bar

## Testing Guidelines

### Test Structure
- **Framework**: Pester 5.x (uses `New-PesterConfiguration` syntax)
- **Test Runner**: `Run-Tests.ps1` - executes all tests, generates NUnit XML
- **Helper Module**: `tests/TestHelpers.ps1` - provides mock functions, test data, environment setup
- **Test Organization**:
  - `tests/unit/` - Function-level tests (Configuration, Logging, PackageManagement, Prerequisites)
  - `tests/integration/` - Full workflow tests (FullSetup.Tests.ps1)

### Test Execution Commands
```powershell
# Run all tests with default settings
.\Run-Tests.ps1

# Run with code coverage
.\Run-Tests.ps1 -EnableCodeCoverage

# Run specific test file
.\Run-Tests.ps1 -TestPath "./tests/unit/Logging.Tests.ps1"

# Run with verbose output
.\Run-Tests.ps1 -Verbosity Detailed
```

### Required Test Patterns
- **BeforeAll**: Dot-source main script and import TestHelpers
- **BeforeEach**: Call `Reset-TestEnvironment` to clear global state
- **Mock Functions**: Use `Set-Mock*` helpers for Windows version, admin check, PowerShell version
- **Global State**: Initialize with `Initialize-TestGlobals` before each test context

## Function Naming Conventions

Follow PowerShell approved verbs:
- `Get-*` - Retrieve information (e.g., `Get-CimInstance`)
- `Set-*` - Configure system state (e.g., `Set-SystemOptimizations`, `Set-WinGetConfiguration`)
- `Test-*` - Validation operations (e.g., `Test-Prerequisites`, `Test-PackageInstallation`)
- `Install-*` - Package installation (e.g., `Install-WinGet`, `Install-Applications`)
- `Invoke-*` - Execute operations (e.g., `Invoke-SafeCommand`)
- `New-*` - Create resources (e.g., `New-SystemRestorePoint`, `New-SSHKeys`)
- `Remove-*` - Delete operations (e.g., `Remove-Bloatware`)
- `Resolve-*` - Compute/calculate (e.g., `Resolve-PackageDependencies`)

## Security Patterns

### Registry Operations
- Always use `-ErrorAction SilentlyContinue` for safety
- Test paths before modification: `Test-Path "HKLM:\..."`
- Registry tweaks in `Set-SystemOptimizations` (lines 550-648)

### Credential Handling
- Git credentials configured via `Set-GitConfiguration` with parameters
- SSH keys generated with `New-SSHKeys` (lines 1944-2000)
- Never log sensitive values - use `[System.Security.SecureString]` if needed

### Windows Security Configuration
- Firewall rules in `Set-DevelopmentFirewallRules` (lines 1073-1121)
- Defender exclusions in `Set-DevelopmentDefenderExclusions` (lines 1124-1159)
- Windows Update config in `Set-WindowsUpdateConfiguration` (lines 1041-1070)

## Reporting System

### HTML Report Generation
`New-SetupReport` function (lines 2660-2990) creates comprehensive HTML report:
- CSS styling embedded in report
- Sections: Overview, Prerequisites, Applications, Security, Errors, Warnings
- Color-coded status indicators (green=success, red=failure, yellow=warning)
- Saved to `$ReportPath` (default: `$env:TEMP\DevMachineSetup_Report.html`)

### JSON Export
System configuration backup via `Export-SystemConfiguration` includes:
- Installed applications list
- Windows version and build
- Network configuration
- Security settings
- Saved alongside HTML report

## Common Development Tasks

### Adding New Package
1. Add entry to `dev-setup-config.json` with name, category, executable
2. If package has dependencies, update `Resolve-PackageDependencies` map
3. Add package-specific WinGet arguments in `Install-PackageWithRetry` switch statement if needed
4. Test installation: `winget install --id <PackageName> --silent`

### Adding New Function
1. Use approved PowerShell verb-noun naming
2. Include comment-based help (`.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.EXAMPLE`)
3. Add logging with `Write-Log` at start/end and error cases
4. Use `Invoke-SafeCommand` for operations requiring retry
5. Update `$Global:SetupReport` with operation status
6. Write Pester tests in appropriate unit test file

### Modifying Setup Flow
1. Main execution flow is in `Main` function (lines 3020-3120)
2. Each phase is gated by parameter flag (e.g., `-SkipWSLInstall`)
3. Add new phase between existing phases, following try/catch pattern
4. Update `$Global:SetupReport` structure if tracking new metrics

## Key Files Reference

- **Main Script**: `lou32dscwin10.ps1` - All functions and execution logic
- **Configuration**: `dev-setup-config.json` - Package definitions
- **Test Runner**: `Run-Tests.ps1` - Pester test execution
- **Test Helpers**: `tests/TestHelpers.ps1` - Mock functions and test utilities
- **Instruction Files**: `.github/instructions/*.instructions.md` - Detailed coding standards
  - `powershell.instructions.md` - PowerShell-specific guidelines
  - `security.instructions.md` - Security best practices
  - `testing.instructions.md` - Test requirements
  - `performance.instructions.md` - Optimization guidelines
  - `documentation.instructions.md` - Documentation standards