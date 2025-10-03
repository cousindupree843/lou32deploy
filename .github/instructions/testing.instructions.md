---
applyTo: '**/*.ps1,**/*.psm1'
description: 'Testing standards and practices for PowerShell automation scripts'
---

# Testing Guidelines for Lou32Deploy

Implement comprehensive testing strategies for PowerShell automation scripts using Pester and integration testing approaches.

## Unit Testing with Pester

- **Test Organization**: Create corresponding .Tests.ps1 files for each PowerShell module
- **Test Structure**: Use Describe/Context/It blocks for clear test organization
- **Mocking**: Mock external dependencies (registry, services, network calls) for unit tests
- **Parameterized Tests**: Use TestCases for testing multiple scenarios with similar logic
- **Assertion Patterns**: Use Should-Be, Should-BeOfType, Should-Throw for clear assertions

## Integration Testing

- **System State Testing**: Test actual system modifications in controlled environments
- **Package Installation**: Verify packages are correctly installed and functional
- **Configuration Validation**: Test registry changes, service states, and file modifications
- **Rollback Testing**: Verify restore points and rollback procedures work correctly
- **Cross-Platform Testing**: Test on different Windows versions (10, 11, Server)

## Test Categories

- **Prerequisites Tests**: Validate system requirements and permissions
- **Installation Tests**: Test package installation with dependency resolution
- **Configuration Tests**: Verify system optimization and security hardening
- **Error Handling Tests**: Test retry logic, failure scenarios, and error recovery
- **Performance Tests**: Validate execution time and resource usage

## Test Data Management

- **Test Isolation**: Each test should be independent and not affect other tests
- **Cleanup Procedures**: Restore system state after tests that modify configuration
- **Test Configuration**: Use separate configuration files for testing scenarios
- **Mock Data**: Create realistic test data for package lists and system configurations

## Continuous Testing

- **Pre-commit Testing**: Run unit tests before committing changes
- **Integration Testing**: Schedule regular integration tests on clean systems
- **Regression Testing**: Maintain tests for previously fixed bugs
- **Documentation Testing**: Validate help documentation and examples work correctly

## Test Reporting

- **Coverage Analysis**: Track code coverage for critical functions
- **Test Results**: Generate XML reports for CI/CD integration
- **Performance Metrics**: Monitor test execution time and system resource usage
- **Security Testing**: Include tests for security configuration validation