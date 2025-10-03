---
applyTo: '**/*.ps1,**/*.psm1'
description: 'Performance optimization guidelines for PowerShell automation'
---

# Performance Guidelines for Lou32Deploy

Optimize PowerShell scripts for efficient execution in enterprise deployment scenarios.

## Script Performance

- **Parallel Execution**: Use background jobs for independent package installations
- **Progress Tracking**: Implement progress bars for long-running operations
- **Memory Management**: Dispose of large objects and clear variables when no longer needed
- **Pipeline Optimization**: Use pipeline operations instead of loops where possible
- **Selective Loading**: Only load required modules and functions

## System Resource Management

- **CPU Usage**: Limit concurrent operations based on system capabilities
- **Memory Constraints**: Monitor memory usage during large package installations
- **Disk I/O**: Optimize file operations and temporary file cleanup
- **Network Bandwidth**: Implement bandwidth throttling for package downloads
- **Process Management**: Clean up background processes and temporary services

## Caching Strategies

- **Package Cache**: Leverage WinGet cache and implement custom caching for dependencies
- **Configuration Cache**: Cache expensive system queries and registry reads
- **Network Cache**: Cache HTTP responses for package metadata and dependency resolution
- **State Caching**: Cache system state checks to avoid repeated expensive operations

## Optimization Techniques

- **Lazy Loading**: Load expensive resources only when needed
- **Batch Operations**: Group similar operations together for efficiency
- **Early Exit**: Implement early exit conditions for validation checks
- **Async Operations**: Use asynchronous patterns for I/O bound operations
- **Resource Pooling**: Reuse expensive objects like web clients and COM objects

## Monitoring and Metrics

- **Execution Time**: Track function execution times for performance regression detection
- **Resource Usage**: Monitor CPU, memory, and disk usage during operations
- **Network Performance**: Track download speeds and retry statistics
- **Operation Counts**: Monitor success/failure ratios for different operations
- **System Impact**: Measure system responsiveness during deployment operations

## Windows-Specific Optimizations

- **Registry Batching**: Batch registry operations to reduce system calls
- **Service Management**: Optimize service start/stop operations
- **File System**: Use appropriate file system APIs for large file operations
- **PowerShell Optimization**: Use PowerShell-specific optimization techniques like splatting