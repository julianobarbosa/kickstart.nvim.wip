# Neovim Configuration Folder Structure

```mermaid
graph TD
    nvim[nvim/]
    init[init.lua]
    lua[lua/]
    after[after/]

    %% Main directories
    nvim --> init
    nvim --> lua
    nvim --> after

    %% Core directory
    core[core/]
    lua --> core
    core --> core_init[init.lua]
    core --> options[options.lua]
    core --> keymaps[keymaps.lua]
    core --> autocmds[autocmds.lua]

    %% Plugins directory
    plugins[plugins/]
    lua --> plugins
    plugins --> plugins_init[init.lua]

    %% Plugin specs
    specs[specs/]
    plugins --> specs
    specs --> editor[editor.lua]
    specs --> ui[ui.lua]
    specs --> lsp[lsp.lua]
    specs --> tools[tools.lua]

    %% Plugin configs
    configs[configs/]
    plugins --> configs
    configs --> lsp_config[lsp.lua]
    configs --> cmp[cmp.lua]
    configs --> treesitter[treesitter.lua]

    %% Utils directory
    utils[utils/]
    lua --> utils

    %% Styling
    classDef default fill:#f9f9f9,stroke:#333,stroke-width:2px;
    classDef file fill:#e1f5fe,stroke:#0288d1;
    classDef directory fill:#fff3e0,stroke:#ff9800;

    %% Apply styles
    class init,core_init,options,keymaps,autocmds,plugins_init,editor,ui,lsp,tools,lsp_config,cmp,treesitter file;
    class nvim,lua,core,plugins,specs,configs,utils,after directory;
