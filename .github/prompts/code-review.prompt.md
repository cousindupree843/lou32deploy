---
mode: 'agent'
model: Claude Sonnet 4
tools: ['codebase', 'problems', 'search', 'usages']
description: 'Comprehensive code review assistance for PowerShell automation code'
---

# Code Review Assistant

Provide comprehensive code review for PowerShell automation code in the Lou32Deploy framework, focusing on quality, security, and maintainability.

## Review Focus Areas

### PowerShell Best Practices
- **Function Design**: Verify adherence to single responsibility principle
- **Naming Conventions**: Check verb-noun naming with approved PowerShell verbs
- **Parameter Design**: Review parameter validation, types, and pipeline support
- **Error Handling**: Evaluate error handling patterns and retry logic implementation
- **Documentation**: Assess comment-based help completeness and accuracy

### Security Analysis
- **Credential Management**: Identify any hardcoded secrets or insecure credential handling
- **Input Validation**: Check for proper sanitization of user inputs and file paths
- **Privilege Requirements**: Verify appropriate privilege checks and escalation
- **Registry Security**: Review registry operations for security vulnerabilities
- **Network Security**: Ensure HTTPS usage and secure connection handling

### Performance Evaluation
- **Resource Management**: Check for memory leaks and proper resource cleanup
- **Concurrent Operations**: Review parallel execution and synchronization
- **Caching Implementation**: Evaluate caching strategies and efficiency
- **System Impact**: Assess potential impact on system performance
- **Progress Reporting**: Verify efficient progress tracking implementation

### Framework Integration
- **Logging Consistency**: Check integration with Write-Log function
- **Configuration Usage**: Verify proper use of Global:Configuration
- **Report Integration**: Ensure Global:SetupReport updates are complete
- **Pattern Adherence**: Confirm following of established Lou32Deploy patterns
- **Dependency Management**: Review dependency resolution implementation

## Review Output Format

Provide structured feedback:
- **Critical Issues**: Security vulnerabilities or breaking changes
- **Major Issues**: Performance problems or significant code quality issues
- **Minor Issues**: Style inconsistencies or improvement suggestions
- **Positive Feedback**: Well-implemented patterns and good practices
- **Recommendations**: Specific improvement suggestions with examples

## Automated Checks Integration

Consider results from:
- **PSScriptAnalyzer**: PowerShell static analysis results
- **Pester Tests**: Test coverage and results
- **Security Scanners**: Automated security vulnerability scans
- **Performance Profiling**: Execution time and resource usage metrics

Generate actionable feedback that helps maintain code quality while preserving the automation framework's reliability and security.