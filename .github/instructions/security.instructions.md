<!-- Based on: https://github.com/github/awesome-copilot/blob/main/instructions/security-and-owasp.instructions.md -->
---
applyTo: '**/*.ps1,**/*.psm1,**/*.json'
description: 'Security best practices for Windows deployment automation'
---

# Security Guidelines for Lou32Deploy

Apply security-first principles to all PowerShell automation code, following OWASP guidelines adapted for Windows deployment scenarios.

## Windows-Specific Security Patterns

- **Principle of Least Privilege**: Run with minimum required permissions, validate administrator rights before privileged operations
- **Registry Security**: Validate all registry paths, use -ErrorAction SilentlyContinue to prevent crashes
- **File System Security**: Validate file paths to prevent directory traversal, use secure temporary directories
- **Service Management**: Verify service exists before attempting to modify, log all service changes

## Credential and Secret Management

- **No Hardcoded Secrets**: Never embed API keys, passwords, or tokens in scripts
- **Environment Variables**: Read secrets from environment variables or secure vaults
- **Masking in Logs**: Ensure sensitive data is not logged or displayed in console output
- **Git Configuration**: Use secure credential helpers, avoid storing passwords in Git config

## Network Security

- **HTTPS Only**: All web requests must use HTTPS
- **Package Source Validation**: Verify WinGet and package manager sources before installation
- **Download Verification**: Validate checksums for downloaded packages when available
- **Firewall Configuration**: Use least-privilege firewall rules for development tools

## System Configuration Security

- **Windows Defender**: Configure exclusions carefully, maintain real-time protection
- **UAC Settings**: Maintain UAC while allowing necessary automation
- **Windows Update**: Ensure automatic updates remain enabled unless explicitly configured
- **SSH Key Management**: Generate strong SSH keys, use different keys for different services

## Input Validation

- **Parameter Validation**: Validate all user inputs, especially file paths and URLs
- **JSON Configuration**: Validate JSON structure and required fields before processing
- **Package Names**: Sanitize package names before passing to WinGet or other installers
- **Registry Values**: Validate registry value types and ranges

## Audit and Logging

- **Security Events**: Log all security-related operations (firewall changes, service modifications)
- **Error Logging**: Log security failures without exposing sensitive information
- **Configuration Changes**: Maintain audit trail of system configuration changes
- **User Actions**: Log actions requiring elevated privileges

## Backup and Recovery Security

- **Restore Point Creation**: Create restore points before major system changes
- **Configuration Backup**: Securely backup system configuration without exposing secrets
- **Recovery Procedures**: Ensure rollback procedures maintain security settings
- **Access Control**: Restrict access to backup files and restore point data