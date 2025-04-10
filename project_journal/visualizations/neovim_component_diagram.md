# Neovim Configuration Component Diagram

```mermaid
graph TB
    %% Main Components
    init[init.lua]
    core[Core Module]
    plugins[Plugins Module]
    utils[Utils Module]
    after[After Module]

    %% Core Subcomponents
    subgraph Core["core/"]
        options[options.lua]
        keymaps[keymaps.lua]
        autocmds[autocmds.lua]
        coreInit[init.lua]
    end

    %% Plugin Subcomponents
    subgraph Plugins["plugins/"]
        pluginInit[init.lua]
        subgraph Specs["specs/"]
            editor[editor.lua]
            ui[ui.lua]
            lsp[lsp.lua]
            tools[tools.lua]
        end
        subgraph Configs["configs/"]
            lspConfig[lsp.lua]
            cmpConfig[cmp.lua]
            tsConfig[treesitter.lua]
        end
    end

    %% Relationships
    init --> core
    init --> plugins
    init --> utils
    init --> after

    pluginInit --> Specs
    pluginInit --> Configs

    %% Plugin-specific relationships
    lsp --> lspConfig
    editor --> cmpConfig
    editor --> tsConfig

    %% Styling
    classDef default fill:#f9f9f9,stroke:#333,stroke-width:2px;
    classDef subgraph fill:#e9e9e9,stroke:#666;
    class Core,Plugins subgraph;
