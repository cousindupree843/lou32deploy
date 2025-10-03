---
mode: 'agent'
model: Claude Sonnet 4
tools: ['codebase', 'editFiles', 'search']
description: 'Refactor PowerShell code for improved maintainability and performance'
---

# Refactor PowerShell Code

Refactor PowerShell automation code in the Lou32Deploy framework to improve maintainability, performance, and adherence to best practices.

## Refactoring Objectives

### Code Quality Improvements
- **Function Decomposition**: Break down large functions into smaller, focused units
- **Code Duplication**: Eliminate duplicate code through shared functions
- **Naming Clarity**: Improve function and variable naming for better readability
- **Pattern Consistency**: Apply consistent patterns across the codebase
- **Error Handling**: Standardize error handling and retry logic

### Performance Optimizations
- **Parallel Processing**: Identify opportunities for concurrent execution
- **Caching Implementation**: Add appropriate caching for expensive operations
- **Resource Management**: Improve memory usage and resource cleanup
- **Pipeline Optimization**: Convert loop operations to pipeline operations
- **Lazy Loading**: Implement lazy loading for expensive resources

### Security Enhancements
- **Input Validation**: Strengthen parameter validation and sanitization
- **Privilege Management**: Implement proper privilege checks and minimal elevation
- **Credential Handling**: Improve secure credential management patterns
- **Error Information**: Prevent sensitive information exposure in errors
- **Audit Trail**: Enhance logging for security-relevant operations

### Framework Integration
- **Logging Standardization**: Ensure consistent use of Write-Log function
- **Configuration Management**: Improve Global:Configuration usage patterns
- **Progress Tracking**: Standardize Write-Progress implementation
- **Reporting Integration**: Enhance Global:SetupReport updates
- **Validation Patterns**: Implement consistent validation approaches

## Refactoring Approach

### Analysis Phase
- **Code Assessment**: Identify problem areas and improvement opportunities
- **Dependency Mapping**: Understand function dependencies and call patterns
- **Performance Profiling**: Identify performance bottlenecks
- **Security Review**: Identify security vulnerabilities or weaknesses
- **Pattern Analysis**: Find inconsistencies in coding patterns

### Implementation Phase
- **Incremental Changes**: Make small, testable changes rather than large rewrites
- **Backward Compatibility**: Maintain existing functionality and interfaces
- **Test Coverage**: Ensure adequate test coverage for refactored code
- **Documentation Updates**: Update documentation to reflect changes
- **Performance Validation**: Verify performance improvements

## Quality Assurance

- **Regression Testing**: Run comprehensive tests to ensure no functionality loss
- **Performance Benchmarking**: Compare before/after performance metrics
- **Security Validation**: Verify security improvements and no new vulnerabilities
- **Code Review**: Submit refactored code for peer review
- **Documentation Review**: Ensure documentation accurately reflects changes

Provide detailed refactoring plan with specific changes, rationale, and validation steps.