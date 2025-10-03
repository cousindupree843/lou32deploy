<!-- Based on: https://github.com/github/awesome-copilot/blob/main/prompts/create-implementation-plan.prompt.md -->
---
mode: 'agent'
model: Claude Sonnet 4
tools: ['codebase', 'editFiles', 'search', 'problems']
description: 'Generate comprehensive documentation for PowerShell functions and modules'
---

# Generate Documentation

Create comprehensive documentation for PowerShell functions and modules in the Lou32Deploy automation framework.

## Documentation Requirements

### Function Documentation
- **Comment-Based Help**: Complete .SYNOPSIS, .DESCRIPTION, .PARAMETER, .EXAMPLE sections
- **Parameter Details**: Comprehensive parameter descriptions with types and validation
- **Usage Examples**: Realistic examples showing common usage patterns
- **Error Handling**: Document expected exceptions and error scenarios
- **Security Notes**: Document privilege requirements and security considerations

### Module Documentation
- **Overview**: Clear description of module purpose and capabilities
- **Architecture**: Explanation of module structure and component relationships
- **Dependencies**: Documentation of external dependencies and requirements
- **Configuration**: Configuration options and their impact on functionality
- **Integration**: How the module integrates with the broader Lou32Deploy framework

### API Documentation
- **Function Signatures**: Complete parameter definitions with types
- **Return Values**: Documentation of return types and possible values
- **Pipeline Support**: Documentation of pipeline input and output behavior
- **State Changes**: Documentation of global state modifications
- **Performance**: Performance characteristics and resource usage notes

## Lou32Deploy Specific Documentation

### Framework Integration
- **Logging Integration**: Document Write-Log usage patterns and categories
- **Configuration Access**: Document Global:Configuration usage and structure
- **Progress Tracking**: Document Write-Progress implementation patterns
- **Error Handling**: Document Invoke-SafeCommand and retry logic usage
- **Reporting Integration**: Document Global:SetupReport update patterns

### Deployment Scenarios
- **Use Cases**: Common deployment scenarios and their requirements
- **Configuration Examples**: Sample JSON configurations for different scenarios
- **Troubleshooting**: Common issues and their solutions
- **Performance Tuning**: Optimization recommendations for different environments
- **Security Hardening**: Security configuration recommendations

## Documentation Formats

### Markdown Documentation
- **README Files**: Clear, structured README files with examples
- **Architecture Diagrams**: Visual representation of system components
- **Workflow Documentation**: Step-by-step process documentation
- **Troubleshooting Guides**: Problem-solution documentation
- **Change Logs**: Detailed change documentation with version history

### PowerShell Help
- **Comment-Based Help**: Proper PowerShell help formatting
- **External Help**: XML-based help files for complex modules
- **About Topics**: Conceptual help topics for framework concepts
- **Examples**: Comprehensive example collections
- **Cross-References**: Links between related functions and concepts

Generate complete, accurate documentation that serves both developers and end users of the Lou32Deploy framework.