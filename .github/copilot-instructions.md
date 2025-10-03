# Lou32Deploy - Windows Development Machine Setup

## Project Overview

Lou32Deploy is a comprehensive PowerShell-based automation framework for setting up Windows development environments. The project provides enterprise-grade machine provisioning with dependency resolution, security hardening, system optimization, and comprehensive reporting.

## Architecture

This project follows a modular architecture with the following key components:

- **Core Setup Scripts**: Main automation scripts for machine configuration
- **Configuration Management**: JSON-based configuration system for customization
- **Dependency Resolution**: Automated package dependency management
- **Security Framework**: Windows security hardening and compliance features
- **Reporting System**: Comprehensive HTML and JSON reporting capabilities
- **Backup & Recovery**: System restore points and configuration backup

## Development Guidelines

### Code Organization
- Maintain clear separation between setup phases (prerequisites, installation, optimization, security)
- Use consistent function naming with approved PowerShell verbs
- Implement proper error handling with retry logic
- Follow the existing logging and progress tracking patterns

### Security First
- All operations must follow principle of least privilege
- Implement proper credential management (no hardcoded secrets)
- Use Windows security best practices for all configurations
- Validate all user inputs and external resources

### Reliability
- Include comprehensive error handling and rollback capabilities
- Implement retry logic for network operations
- Provide clear progress tracking and user feedback
- Ensure idempotent operations where possible

### Testing Strategy
- Write Pester tests for all new functions
- Test both success and failure scenarios
- Include integration tests for complete workflows
- Validate security configurations after changes

## Key Technologies

- **PowerShell 5.1+**: Primary scripting language
- **WinGet**: Package management
- **Windows Registry**: System configuration
- **Windows Security**: Defender, Firewall, UAC configuration
- **WSL**: Windows Subsystem for Linux setup
- **Development Tools**: Git, VS Code, Docker, Node.js, Python, .NET

## Contributing

When adding new features:
1. Follow the existing code patterns and structure
2. Add comprehensive logging and error handling
3. Update configuration schema if needed
4. Include progress tracking for user operations
5. Write appropriate tests and documentation
6. Ensure security compliance

Refer to the specific instruction files in `.github/instructions/` for detailed coding standards and best practices.