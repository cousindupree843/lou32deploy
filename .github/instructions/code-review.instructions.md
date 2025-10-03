---
applyTo: '**/*.ps1,**/*.md'
description: 'Code review standards and GitHub review guidelines for Lou32Deploy'
---

# Code Review Guidelines

Establish comprehensive code review standards for maintaining high-quality PowerShell automation code.

## Review Checklist

### PowerShell Code Quality
- **Function Design**: Verify functions follow single responsibility principle
- **Parameter Validation**: Check for proper input validation and type checking
- **Error Handling**: Ensure comprehensive error handling with appropriate retry logic
- **Logging Integration**: Confirm proper use of Write-Log function with categories
- **Progress Tracking**: Verify Write-Progress implementation for long operations

### Security Review
- **Credential Handling**: Ensure no hardcoded secrets or exposed credentials
- **Registry Operations**: Validate registry paths and error handling
- **File System Security**: Check for path traversal vulnerabilities
- **Privilege Escalation**: Verify appropriate privilege requirements and checks
- **Network Security**: Confirm HTTPS usage and secure connection handling

### Performance Considerations
- **Resource Usage**: Check for memory leaks and resource cleanup
- **Parallel Operations**: Review concurrent execution and synchronization
- **Caching Implementation**: Verify efficient caching strategies
- **Progress Reporting**: Ensure progress tracking doesn't impact performance
- **System Impact**: Review system resource usage during operations

### Documentation Review
- **Function Documentation**: Verify comment-based help completeness
- **Code Comments**: Check for clear explanations of complex logic
- **Parameter Documentation**: Ensure all parameters are documented with examples
- **Change Documentation**: Verify changelog and version documentation updates

## GitHub Review Process

### Pull Request Standards
- **Branch Naming**: Use descriptive branch names (feature/, bugfix/, hotfix/)
- **Commit Messages**: Clear, descriptive commit messages following conventional commits
- **PR Description**: Include clear description of changes and testing performed
- **Breaking Changes**: Highlight any breaking changes or migration requirements

### Review Responsibilities
- **Functionality**: Verify changes meet requirements and work as expected
- **Testing**: Ensure appropriate tests are included and pass
- **Security**: Review for security implications and vulnerabilities
- **Performance**: Check for performance impact and optimizations
- **Documentation**: Verify documentation updates match code changes

### Approval Criteria
- **Code Quality**: Code follows established patterns and conventions
- **Test Coverage**: Adequate test coverage for new functionality
- **Security Compliance**: No security vulnerabilities introduced
- **Documentation**: All changes properly documented
- **Backward Compatibility**: Changes don't break existing functionality

## Automated Checks

### CI/CD Integration
- **Linting**: PowerShell script analyzer (PSScriptAnalyzer) checks
- **Testing**: Automated Pester test execution
- **Security Scanning**: Automated security vulnerability scanning
- **Documentation**: Automated documentation generation and validation