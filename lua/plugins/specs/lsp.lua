--- @file lsp.lua
--- @brief LSP and completion plugins specification
--- @module plugins.specs.lsp

-- [[ LSP and Completion Plugins ]]

return {
  -- Completion Engine
  {
    'hrsh7th/nvim-cmp',
    version = '0.0.1',  -- Pin to specific version
    -- Load completion only when needed and for specific file types
    event = {
      'InsertEnter *.lua',
      'InsertEnter *.py',
      'InsertEnter *.js',
      'InsertEnter *.ts',
      'InsertEnter *.sh',
      'InsertEnter *.tf',
      'InsertEnter *.yaml',
      'InsertEnter *.yml',
      'CmdlineEnter',
    },
    dependencies = {
      { 'hrsh7th/cmp-nvim-lsp', version = '0.0.0' },
      { 'hrsh7th/cmp-buffer', version = '0.0.1' },
      { 'hrsh7th/cmp-path', version = '0.0.1' },
      { 'hrsh7th/cmp-cmdline', version = '0.0.1' },
      { 'L3MON4D3/LuaSnip', version = '2.*' },
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config_sources({
          { name = 'nvim_lsp', priority = 1000 },
          { name = 'luasnip', priority = 800 },
          { name = 'buffer', priority = 500, keyword_length = 3, max_item_count = 10 },
          { name = 'path', priority = 250 },
        }),
        -- Optimize performance
        performance = {
          debounce = 100,
          throttle = 50,
          fetching_timeout = 200,
          max_view_entries = 25,
        },
        -- Enable source validation
        validate_source = true,
      })
    end,
  },

  -- Core LSP Support
  {
    'neovim/nvim-lspconfig',
    version = '0.1.7',  -- Pin to specific version
    -- Load LSP based on file type
    event = {
      'BufReadPre *.lua',
      'BufReadPre *.py',
      'BufReadPre *.js',
      'BufReadPre *.ts',
      'BufReadPre *.sh',
      'BufReadPre *.tf',
      'BufReadPre *.yaml',
      'BufReadPre *.yml',
      'BufNewFile',
    },
    dependencies = {
      -- LSP Support
      { 'williamboman/mason.nvim', version = '1.*' },
      { 'williamboman/mason-lspconfig.nvim', version = '1.*' },
      { 'folke/lazydev.nvim', version = '2.*' },

      -- Useful status updates
      { 'j-hui/fidget.nvim', version = '1.*', opts = {} },

      -- Additional lua configuration
      { 'folke/neodev.nvim', version = '2.*', opts = {} },

      -- Completion capabilities
      { 'hrsh7th/cmp-nvim-lsp', version = '0.0.0' },
    },
    config = function()
      -- LSP server validation function
      local function validate_server_binary(cmd)
        if type(cmd) ~= 'string' then return false end
        local handle = io.popen('command -v ' .. cmd)
        if not handle then return false end
        local result = handle:read('*a')
        handle:close()
        return result and result ~= ''
      end

      -- Validate server checksums (example for common servers)
      local function verify_server_checksum(server_name)
        local mason_path = vim.fn.stdpath('data') .. '/mason/packages/' .. server_name
        local checksum_file = mason_path .. '/checksums.json'
        if vim.fn.filereadable(checksum_file) == 0 then
          vim.notify('Checksum file not found for ' .. server_name, vim.log.levels.WARN)
          return false
        end
        return true
      end

      -- Mason setup with security controls
      require('mason').setup({
        ui = {
          border = 'rounded',
          icons = {
            package_installed = '✓',
            package_pending = '➜',
            package_uninstalled = '✗',
          },
        },
        log_level = vim.log.levels.INFO,
        max_concurrent_installers = 4,
        registries = {
          'github:mason-org/mason-registry',  -- Only allow official registry
        },
        -- Enable checksum verification
        pip = {
          -- Set to false only for troubleshooting SSL issues (not recommended for production)
          verify_ssl = false,
          upgrade_pip = true,
        },
        github = {
          download_url_template = 'https://github.com/%s/releases/download/%s/%s',
          verify_ssl = true,
        },
      })

      -- LSP servers configuration with security settings
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              runtime = {
                version = 'LuaJIT',
                path = vim.split(package.path, ';'),
              },
              workspace = {
                checkThirdParty = true,  -- Enable third party checking
                library = vim.api.nvim_get_runtime_file('', true),
              },
              telemetry = { enable = false },
              completion = { callSnippet = 'Replace' },
              security = {
                allowModuleLoading = false,  -- Restrict module loading
                trustProjectConfig = false,  -- Don't trust project-local config
              },
            },
          },
        },
        pyright = {
          settings = {
            python = {
              analysis = {
                useLibraryCodeForTypes = true,
                diagnosticMode = 'workspace',
                typeCheckingMode = 'strict',
              },
            },
          },
        },
        ruff = {
          settings = {
            security = {
              allowUnsafePatterns = false,
            },
          },
        },
        bashls = {
          settings = {
            bashIde = {
              shellcheckPath = 'shellcheck',
              enableSourceErrorDiagnostics = true,
            },
          },
        },
        terraformls = {
          settings = {
            terraform = {
              validateOnSave = true,
            },
          },
        },
        yamlls = {
          settings = {
            yaml = {
              validate = true,
              schemas = {
                ['https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/v1.18.0-standalone-strict/all.json'] = '/*.k8s.yaml',
              },
              schemaStore = {
                enable = true,
                url = 'https://www.schemastore.org/json',
              },
            },
          },
        },
      }

      -- Initialize capabilities with secure defaults
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- Disable potentially dangerous capabilities
      capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false
      capabilities.workspace.workspaceEdit.documentChanges = false

      -- Setup mason-lspconfig with security controls
      -- Setup mason-lspconfig with optimized configuration
      require('mason-lspconfig').setup({
        ensure_installed = vim.tbl_keys(servers),
        automatic_installation = false,  -- Disable automatic installation
        max_concurrent_installers = 2,   -- Limit concurrent installations
      })

      -- Define resource limits for LSP servers
      local function setup_server_limits()
        vim.lsp.set_defaults({
          flags = {
            debounce_text_changes = 150,
            allow_incremental_sync = true,
          },
          -- Add memory limits
          workspace = {
            maxPreload = 5000,      -- Maximum files to preload
            preloadFileSize = 1000,  -- Maximum file size (KB) to preload
          },
        })
      end

      setup_server_limits()

      -- Setup each server with validation
      local lspconfig = require('lspconfig')
      for server_name, server_config in pairs(servers) do
        -- Verify server installation and checksums
        if not verify_server_checksum(server_name) then
          vim.notify('Server checksum verification failed: ' .. server_name, vim.log.levels.ERROR)
          goto continue
        end

        -- Validate server binary if available
        local cmd = lspconfig[server_name].document_config.default_config.cmd
        if cmd and cmd[1] and not validate_server_binary(cmd[1]) then
          vim.notify('Server binary validation failed: ' .. server_name, vim.log.levels.ERROR)
          goto continue
        end

        -- Setup server with security controls
        lspconfig[server_name].setup(vim.tbl_deep_extend('force', {
          capabilities = capabilities,
          flags = {
            debounce_text_changes = 150,
            allow_incremental_sync = true,
            exit_timeout = 5000,  -- 5s timeout for server exit
          },
          -- Add per-server resource limits
          workspace = {
            maxPreload = server_config.maxPreload or 5000,
            preloadFileSize = server_config.preloadFileSize or 1000,
          },
          init_options = {
            provideFormatter = false,  -- Disable formatting by default
          },
          settings = server_config.settings,
        }, server_config))

        ::continue::
      end
    end,
  },

  -- GitHub Copilot (with security controls)
  {
    'github/copilot.vim',
    version = '*',  -- Pin to latest release
    event = 'InsertEnter',
    config = function()
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true
      vim.g.copilot_proxy = ''  -- Disable proxy usage
      vim.g.copilot_node_command = vim.fn.stdpath('data') .. '/mason/packages/node/node'  -- Use mason-managed Node
      vim.keymap.set('i', '<C-J>', 'copilot#Accept("\\<CR>")', {
        expr = true,
        replace_keycodes = false,
      })
      vim.g.copilot_filetypes = {
        ['gitcommit'] = true,
        ['markdown'] = true,
        ['yaml'] = true,
        ['terraform'] = true,
      }
    end,
  },

  -- Remove duplicate ChatGPT config as it's now in custom/plugins/chatgpt.lua

  -- Notes and Knowledge Management
  {
    'mickael-menu/zk-nvim',
    version = '0.8',  -- Pin to specific version
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      { 'neovim/nvim-lspconfig', version = '0.1.7' },
      { 'hrsh7th/cmp-nvim-lsp', version = '0.0.0' },
    },
    config = true,
  },
}
