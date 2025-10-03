<!-- Based on: https://github.com/github/awesome-copilot/blob/main/chatmodes/debug.chatmode.md -->
---
mode: 'agent'
model: Claude Sonnet 4
tools: ['codebase', 'problems', 'search', 'usages', 'runCommands']
description: 'Debug PowerShell automation issues in Lou32Deploy framework'
---

# Debug PowerShell Issues

Systematically debug issues in the Lou32Deploy PowerShell automation framework using structured troubleshooting approach.

## Phase 1: Problem Assessment

### Gather Context
- **Error Analysis**: Examine error messages, stack traces, and failure reports
- **Environment Details**: Check Windows version, PowerShell version, execution policy
- **Recent Changes**: Review recent code changes, configuration modifications
- **System State**: Check system resources, running processes, and services
- **Log Analysis**: Review Write-Log output and Global:SetupReport data

### Reproduce the Issue
- **Execution Environment**: Run in similar environment to original failure
- **Parameter Testing**: Test with same parameters and configuration
- **Isolation Testing**: Test individual functions in isolation
- **Documentation**: Create detailed reproduction steps and expected vs actual behavior

## Phase 2: Investigation

### Root Cause Analysis
- **Code Flow Tracing**: Follow execution path through Lou32Deploy functions
- **Variable State**: Examine Global:Configuration and Global:SetupReport states
- **External Dependencies**: Check WinGet, registry, services, and network connectivity
- **Permission Issues**: Verify administrator rights and UAC settings
- **Resource Constraints**: Check memory, disk space, and network resources

### Common Issue Patterns
- **Package Installation**: WinGet errors, dependency resolution failures
- **Registry Operations**: Access denied, invalid paths, type mismatches
- **Service Management**: Service not found, permission denied, timeout issues
- **Network Operations**: Connectivity issues, SSL/TLS problems, proxy settings
- **File System**: Path issues, permissions, disk space, file locks

## Phase 3: Resolution

### Systematic Debugging
- **Logging Enhancement**: Add detailed logging to trace execution
- **Error Handling**: Implement proper error handling with retry logic
- **Validation**: Add input validation and state checking
- **Progress Tracking**: Enhance progress reporting for better visibility
- **Resource Management**: Ensure proper cleanup and resource disposal

### Lou32Deploy Patterns
- **Invoke-SafeCommand**: Use for operations requiring retry logic
- **Write-Log Integration**: Ensure proper logging with categories and levels
- **Global State Management**: Verify Global:SetupReport updates
- **Configuration Validation**: Check Global:Configuration structure and values
- **Dependency Resolution**: Follow established dependency patterns

## Phase 4: Validation

### Testing Strategy
- **Unit Testing**: Create Pester tests for the fixed functionality
- **Integration Testing**: Test in realistic deployment scenarios
- **Regression Testing**: Ensure fix doesn't break existing functionality
- **Performance Testing**: Verify fix doesn't impact performance
- **Security Testing**: Ensure security implications are addressed

### Documentation
- **Fix Documentation**: Document the root cause and solution
- **Prevention Measures**: Add validation or checks to prevent recurrence
- **Troubleshooting Guide**: Update documentation with common issues
- **Knowledge Base**: Add to troubleshooting knowledge base

Focus on systematic diagnosis before implementing fixes, and ensure all changes follow Lou32Deploy patterns and conventions.