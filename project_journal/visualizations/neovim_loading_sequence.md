# Neovim Configuration Loading Sequence

```mermaid
sequenceDiagram
    participant I as init.lua
    participant C as core/init.lua
    participant P as plugins/init.lua
    participant S as plugins/specs/*
    participant CF as plugins/configs/*
    participant A as after/*

    Note over I: Start Neovim

    I->>C: Load core module
    activate C
    C->>C: Load options.lua
    C->>C: Load keymaps.lua
    C->>C: Load autocmds.lua
    C-->>I: Core settings applied
    deactivate C

    I->>P: Initialize plugin manager
    activate P
    P->>S: Load plugin specifications
    activate S
    S-->>P: Return plugin list
    deactivate S

    P->>P: Install missing plugins

    loop For each plugin
        P->>CF: Load plugin configuration
        Note over CF: Setup plugin with<br/>specific settings
        CF-->>P: Configuration applied
    end

    P-->>I: Plugins initialized
    deactivate P

    I->>A: Load post-initialization
    activate A
    Note over A: Handle any final<br/>configurations
    A-->>I: Setup complete
    deactivate A

    Note over I: Neovim ready
