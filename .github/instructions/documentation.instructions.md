---
applyTo: '**/*.md,**/*.ps1'
description: 'Documentation standards for Lou32Deploy automation framework'
---

# Documentation Guidelines

Maintain comprehensive documentation for the Lou32Deploy automation framework with focus on usability and maintainability.

## Code Documentation

- **Function Documentation**: Use PowerShell comment-based help with .SYNOPSIS, .DESCRIPTION, .PARAMETER, .EXAMPLE
- **Inline Comments**: Explain complex logic, security considerations, and business requirements
- **Change Documentation**: Document rationale for configuration changes and registry modifications
- **Error Handling**: Document expected exceptions and recovery procedures

## User Documentation

- **README Structure**: Clear installation, usage, and troubleshooting sections
- **Parameter Documentation**: Document all script parameters with examples
- **Configuration Guide**: Explain JSON configuration options and their impact
- **Troubleshooting Guide**: Common issues, solutions, and diagnostic steps

## Technical Documentation

- **Architecture Overview**: Document system components and their interactions
- **Dependency Mapping**: Explain package dependencies and installation order
- **Security Model**: Document security hardening steps and their purpose
- **Performance Considerations**: Document optimization techniques and their trade-offs

## Operational Documentation

- **Deployment Guide**: Step-by-step deployment procedures for different environments
- **Rollback Procedures**: Clear instructions for system recovery and restore points
- **Monitoring Guide**: How to interpret logs, reports, and system health indicators
- **Maintenance Tasks**: Regular maintenance procedures and schedules

## Documentation Formats

- **Markdown Standards**: Use consistent formatting, headers, and code blocks
- **PowerShell Examples**: Include realistic examples with expected output
- **JSON Schemas**: Document configuration file structure and validation rules
- **Workflow Diagrams**: Visual representation of complex processes

## Version Control

- **Change Logs**: Maintain detailed change logs with version numbers
- **Breaking Changes**: Clearly document breaking changes and migration paths
- **Deprecation Notices**: Provide advance notice of deprecated features
- **Compatibility Matrix**: Document Windows version and PowerShell version compatibility