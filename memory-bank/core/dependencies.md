---
last_updated: 2025-04-07 10:57
version: 1.0.0
status: active
related_files: [core/productContext.md, core/systemPatterns.md]
tags: [dependencies, core, architecture]
---

# Project Dependencies

This file tracks and documents all project dependencies, their versions, and relationships.

## Core Dependencies
1. Language Servers (managed by Mason)
   - lua_ls: For Lua development
   - pyright: For Python development
   - bashls: For shell script support
   - dockerls: For Dockerfile editing
   - terraformls: For Terraform files
   - yamlls: For YAML configuration
   - ansiblels: For Ansible playbooks

2. Plugin Management
   - lazy.nvim: Plugin manager
   - mason.nvim: LSP/DAP/Linter manager

3. Development Tools
   - nvim-dap: Debug Adapter Protocol support
   - nvim-dap-ui: Debugging interface
   - nvim-cmp: Completion engine

[2025-04-07 16:25:12] - Added initial dependency documentation
