# ADR: Neovim Configuration Architecture Refactor

**Status:** Proposed

**Context:**
The current Neovim configuration faces several architectural challenges:
1. Configuration fragmentation between "custom" and "kickstart" directories
2. Plugin configuration redundancy
3. Duplicate keymap definitions
4. Inconsistent coding styles
5. Performance concerns from loading patterns

**Decision:**
Implement a new modular architecture with clear separation of concerns:

```
nvim/
├── init.lua                 # Main entry point
├── lua/
│   ├── core/               # Core configuration
│   │   ├── init.lua        # Core module loader
│   │   ├── options.lua     # Vim options
│   │   ├── keymaps.lua     # Global keymaps
│   │   └── autocmds.lua    # Global autocommands
│   ├── plugins/            # Plugin configuration
│   │   ├── init.lua        # Plugin loader
│   │   ├── specs/          # Plugin specifications
│   │   │   ├── editor.lua  # Editor enhancements
│   │   │   ├── ui.lua      # UI plugins
│   │   │   ├── lsp.lua     # LSP configurations
│   │   │   └── tools.lua   # Development tools
│   │   └── configs/        # Plugin-specific configs
│   │       ├── lsp.lua     # LSP setup
│   │       ├── cmp.lua     # Completion
│   │       └── treesitter.lua
│   └── utils/              # Utility functions
└── after/                  # Post-load configurations
```

**Key Architectural Principles:**

1. **Modular Organization**
   - Each plugin category has its own specification file
   - Plugin configurations are separated from their loading definitions
   - Common utilities are centralized

2. **Plugin Management**
   - Single source of truth for plugin specifications
   - Lazy-loading by default using events and commands
   - Clear dependencies and load order

3. **Keymap Management**
   - Global keymaps in core/keymaps.lua
   - Plugin-specific keymaps in respective plugin config files
   - Consistent format using descriptive tables

4. **Configuration Patterns**
   - Standardized configuration format across all files
   - Clear separation between core Neovim settings and plugin configurations
   - Consistent use of Lua APIs and coding style

**Loading Strategy:**
1. core/* loads first with essential settings
2. plugins/init.lua manages plugin installation
3. plugins/specs/* defines what to load
4. plugins/configs/* contains the actual setup
5. after/* handles any post-initialization requirements

**Migration Strategy:**
1. Create new directory structure
2. Move core settings from init.lua to appropriate core/* files
3. Consolidate plugin configurations from custom/ and kickstart/
4. Migrate keymaps to their proper locations
5. Update loading patterns for improved performance

**Coding Standards:**
1. Use stylua for formatting (with .stylua.toml configuration)
2. Consistent commenting style for documentation
3. Clear function and variable naming conventions
4. Error handling patterns for plugin loading

**Rationale:**
- Clear separation of concerns improves maintainability
- Modular structure makes it easier to add/remove features
- Centralized plugin management reduces redundancy
- Standardized patterns improve code quality
- Lazy-loading improves startup performance

**Consequences:**

Positive:
- Better organization and maintainability
- Reduced redundancy
- Improved performance through better loading patterns
- Easier to add new plugins or modify existing ones
- Clear documentation and standards

Negative:
- Initial migration effort required
- Need to update existing custom configurations
- Learning curve for new structure

**Implementation Notes:**
- Use init.lua as a minimal bootstrap file
- Implement lazy-loading for all non-essential plugins
- Create utility functions for common operations
- Document all public APIs and configuration options
