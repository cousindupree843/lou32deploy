<!-- Based on: https://github.com/github/awesome-copilot/blob/main/instructions/powershell.instructions.md -->
---
applyTo: '**/*.ps1,**/*.psm1'
description: 'PowerShell cmdlet and scripting best practices for Lou32Deploy automation framework'
---

# PowerShell Development Guidelines

Apply PowerShell-specific coding standards and best practices for the Lou32Deploy automation framework. Follow Microsoft's PowerShell cmdlet development guidelines.

## Naming Conventions

- **Verb-Noun Format**: Use approved PowerShell verbs (Get-Verb) with singular nouns in PascalCase
- **Parameter Names**: Use PascalCase with clear, descriptive names following PowerShell standards
- **Variable Names**: Use PascalCase for public variables, camelCase for private variables
- **Avoid Aliases**: Use full cmdlet names in scripts (Get-ChildItem instead of gci)
- **Function Names**: Follow existing patterns like Set-SystemOptimizations, Install-PackageWithRetry

## Parameter Design

- Use common parameter names (Path, Name, Force) following built-in cmdlet conventions
- Implement proper validation with ValidateSet for limited options
- Use [switch] parameters for boolean flags defaulting to false
- Enable pipeline support with ValueFromPipeline and ValueFromPipelineByPropertyName
- Include comprehensive parameter documentation

## Error Handling and Safety

- **ShouldProcess Implementation**: Use [CmdletBinding(SupportsShouldProcess = $true)] for system changes
- **Message Streams**: Use Write-Verbose for operational details, Write-Warning for warnings, Write-Error for non-terminating errors
- **Retry Logic**: Follow existing patterns with exponential backoff for network operations
- **Non-Interactive Design**: Accept input via parameters, avoid Read-Host in automated scenarios
- **Logging Integration**: Use the existing Write-Log function with appropriate categories and levels

## Pipeline and Output

- **Pipeline Support**: Implement Begin/Process/End blocks for pipeline handling
- **Rich Objects**: Return PSCustomObject for structured data, not formatted text
- **PassThru Pattern**: Default to no output for action cmdlets, implement -PassThru switch for object return
- **Progress Tracking**: Use the existing Write-Progress function for long-running operations

## Lou32Deploy Specific Patterns

- **Configuration Access**: Use the Global:Configuration variable for settings
- **Reporting Integration**: Update Global:SetupReport for all operations
- **Dependency Resolution**: Follow existing Resolve-PackageDependencies patterns
- **Validation Functions**: Implement Test-* functions for validation operations
- **Safe Command Execution**: Use Invoke-SafeCommand for operations requiring retry logic

## Documentation Standards

- **Comment-Based Help**: Include .SYNOPSIS, .DESCRIPTION, .EXAMPLE, .PARAMETER sections
- **Consistent Formatting**: Use 4-space indentation, opening braces on same line
- **Pipeline Documentation**: Document ValueFromPipeline behavior and expected input types
- **Error Documentation**: Document expected exceptions and error handling behavior

## Security Considerations

- **Credential Handling**: Never log or expose credentials in output
- **Registry Operations**: Validate registry paths and use -ErrorAction SilentlyContinue for safety
- **File Operations**: Use secure file paths and validate user inputs
- **Admin Requirements**: Clearly document functions requiring administrator privileges