---
mode: 'agent'
model: Claude Sonnet 4
tools: ['codebase', 'editFiles', 'runCommands']
description: 'Generate comprehensive Pester tests for PowerShell functions'
---

# Write Pester Tests

Generate comprehensive Pester tests for PowerShell functions in the Lou32Deploy automation framework.

## Test Structure Requirements

Create tests following Pester best practices:
- Use Describe/Context/It blocks for clear organization
- Include both positive and negative test cases
- Test parameter validation and error conditions
- Mock external dependencies (registry, services, network)
- Test integration with logging and progress tracking systems

## Test Categories

### Unit Tests
- **Parameter Validation**: Test all parameter combinations and validation rules
- **Function Logic**: Test core functionality with various inputs
- **Error Handling**: Test exception scenarios and retry logic
- **Output Validation**: Verify correct return types and values
- **State Management**: Test global variable updates and cleanup

### Integration Tests
- **System Integration**: Test actual system modifications in safe environments
- **Dependency Chain**: Test function interactions and dependency resolution
- **Configuration Integration**: Test with various configuration scenarios
- **Security Validation**: Test security-related operations and validations
- **Performance Testing**: Test execution time and resource usage

## Mocking Strategies

Mock external dependencies:
- **Registry Operations**: Mock Get-ItemProperty, Set-ItemProperty, etc.
- **Service Management**: Mock Get-Service, Start-Service, Stop-Service
- **Network Operations**: Mock Invoke-WebRequest, Invoke-RestMethod
- **File System**: Mock Get-Content, Set-Content, Test-Path
- **System Commands**: Mock external executables and their output

## Test Data Management

- **Isolation**: Ensure tests don't affect each other or system state
- **Cleanup**: Implement proper cleanup in AfterEach/AfterAll blocks
- **Test Configuration**: Use separate configuration files for testing
- **Realistic Data**: Create test data that represents real-world scenarios
- **Edge Cases**: Include boundary conditions and error scenarios

## Lou32Deploy Specific Testing

Test framework-specific functionality:
- **Logging Integration**: Verify Write-Log calls with correct parameters
- **Progress Tracking**: Test Write-Progress implementation
- **Global State**: Test updates to Global:SetupReport and Global:Configuration
- **Error Patterns**: Test Invoke-SafeCommand usage and retry logic
- **Validation Functions**: Test corresponding Test-* functions

Provide complete test files with proper setup, teardown, and comprehensive coverage.