---
mode: 'agent'
model: Claude Sonnet 4
tools: ['codebase', 'editFiles', 'problems']
description: 'Create a new PowerShell function for Lou32Deploy automation framework'
---

# Create PowerShell Function

Your goal is to create a new PowerShell function for the Lou32Deploy automation framework following established patterns and conventions.

## Requirements Analysis

Before creating the function, analyze:
- Function purpose and scope within the deployment framework
- Required parameters and their validation requirements
- Integration with existing logging and progress tracking systems
- Error handling and retry logic requirements
- Security considerations for Windows system modifications

## Function Structure

Create functions following the Lou32Deploy patterns:
- Use approved PowerShell verbs (Get-, Set-, Install-, Test-, etc.)
- Implement proper parameter validation with types and constraints
- Include comprehensive comment-based help
- Use existing Write-Log function for logging with appropriate categories
- Implement Write-Progress for long-running operations
- Follow existing error handling patterns with Invoke-SafeCommand

## Integration Requirements

Ensure proper integration with:
- **Global Configuration**: Use `$Global:Configuration` for settings
- **Reporting System**: Update `$Global:SetupReport` for tracking
- **Dependency Management**: Follow existing dependency resolution patterns
- **Security Framework**: Implement appropriate security checks
- **Validation System**: Create corresponding Test-* validation functions

## Code Quality Standards

Follow established conventions:
- Use consistent indentation and formatting
- Implement proper pipeline support where appropriate
- Include realistic examples in comment-based help
- Use descriptive variable names and avoid aliases
- Implement proper disposal of resources and cleanup

## Testing Considerations

Include guidance for:
- Unit test creation with Pester
- Integration testing requirements
- Mock strategies for external dependencies
- Test data management and cleanup procedures

Provide the complete function implementation with proper documentation and integration points.