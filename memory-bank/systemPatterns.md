# Neovim Configuration System Patterns

## Architecture Overview
```
.
├── init.lua                 # Main configuration entry point
└── lua/
    └── kickstart/
        └── plugins/        # Plugin-specific configurations
            ├── debug.lua   # DAP debugging setup
            ├── lint.lua    # nvim-lint configuration
            └── autopairs.lua # Auto-pairing setup
```

## Core Patterns

### Plugin Organization
- Lazy.nvim for plugin management and lazy loading
- Modular plugin configuration files
- Clear separation of concerns per plugin
- Event-based plugin loading for better startup time

### LSP Integration
- Mason.nvim for LSP server management
- Comprehensive language server configurations
- Integrated completion with nvim-cmp
- Automatic server installation and setup

### Development Tools Integration
1. Debugging System
   - nvim-dap for debug adapter protocol support
   - Language-specific debug configurations (Go, Python)
   - Integrated debug UI with nvim-dap-ui
   - Custom keymaps for debug operations

2. Linting Framework
   - File-type specific linters
   - Automatic lint on events (BufEnter, BufWritePost, InsertLeave)
   - Configurable linter selection per filetype
   - Integration with LSP diagnostics

3. Code Completion
   - nvim-cmp as completion engine
   - LSP-based completions
   - Snippet integration
   - Auto-pairs integration for brackets/quotes

## Component Relationships
1. Plugin Manager (lazy.nvim) → Plugin Configurations
2. LSP Layer → Language Servers → Code Intelligence
3. Debug Adapters → DAP UI → User Interface
4. Linters → Diagnostic Framework → Error Reporting

## Design Decisions
1. Event-driven plugin loading for performance
2. Modular configuration for maintainability
3. Extensive use of built-in LSP capabilities
4. Integration between complementary tools (LSP, DAP, Linters)


## Python Virtual Environments

It is highly recommended to use Python virtual environments for this project to isolate dependencies and ensure reproducibility.

### Creating a Virtual Environment

```bash
python3 -m venv .venv
```

### Activating the Virtual Environment

```bash
source .venv/bin/activate
```

### Deactivating the Virtual Environment

```bash
deactivate
```

<!-- The following section is deprecated. Use uv instead. -->
### Installing Dependencies

It is recommended to use `uv` for faster dependency resolution and installation.

```bash
uv pip install -r requirements.txt
```

### Installing uv

```bash
curl -LsSf https://install.astral.sh | sh
```

### Using uv

```bash
uv venv .venv
source .venv/bin/activate
uv pip install -r requirements.txt
uv python script.py
```

### Benefits of uv

`uv` offers significant performance improvements over `pip` due to its efficient dependency resolution and caching mechanisms. It is also designed to be more reliable and provide better error messages.
