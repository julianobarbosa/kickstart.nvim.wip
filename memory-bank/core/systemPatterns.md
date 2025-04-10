---
last_updated: 2025-04-10 12:23
version: 1.0.0
status: active
related_files: [core/productContext.md, core/dependencies.md]
tags: [system, patterns, configuration, environment]
---

# System Patterns and Environment Configuration

## Python Environment

### Global Tools Virtual Environment
- Location: `~/.venv/tools3`
- Activation: `source ~/.venv/tools3/bin/activate`
- Purpose: Houses global Python tools and LSP servers
- Used for: Global development tools like:
  - Language servers (pyright, ruff-lsp)
  - Code formatters
  - Development utilities

## Node.js Environment

### Version Management
- Tool: nvm (Node Version Manager)
- Purpose: Manages Node.js versions and global npm packages
- Used for: JavaScript/TypeScript development tools:
  - Language servers (typescript-language-server, eslint-language-server)
  - Linters and formatters
  - Development utilities

## Best Practices
1. Python Tools:
   - Use the tools3 virtual environment for global development tools
   - Keep project-specific dependencies in project-specific virtual environments
   - Ensure the tools3 environment is activated when installing or updating global Python tools

2. Node.js Tools:
   - Use nvm to manage Node.js versions and global packages
   - Install language servers and development tools globally with npm
   - Ensure correct Node.js version is active when installing or updating tools
