--- @file lsp.lua
--- @brief LSP and completion plugins specification
--- @module plugins.specs.lsp

-- [[ LSP and Completion Plugins ]]

return {
  -- Completion Engine
  {
    'hrsh7th/nvim-cmp',
    event = { 'InsertEnter', 'CmdlineEnter' },
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'L3MON4D3/LuaSnip',
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
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        }),
      })
    end,
  },

  -- Core LSP Support
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      -- LSP Support
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'folke/lazydev.nvim',

      -- Useful status updates
      { 'j-hui/fidget.nvim', opts = {} },

      -- Additional lua configuration
      { 'folke/neodev.nvim', opts = {} },

      -- Completion capabilities
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      -- Mason setup
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
      })

      -- LSP servers configuration
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
              completion = { callSnippet = 'Replace' },
            },
          },
        },
        pyright = {},
        ruff = {},
        bashls = {},
        terraformls = {},
        yamlls = {
          schemas = {
            ['https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/v1.18.0-standalone-strict/all.json'] = '/*.k8s.yaml',
          },
        },
      }

      -- Initialize capabilities with LSP and nvim-cmp defaults
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- Ensure servers are installed
      require('mason-lspconfig').setup({
        ensure_installed = vim.tbl_keys(servers),
        automatic_installation = true,
      })

      -- Setup each server
      local lspconfig = require('lspconfig')
      for server_name, server_config in pairs(servers) do
        lspconfig[server_name].setup({
          capabilities = capabilities,
          settings = server_config.settings,
        })
      end
    end,
  },

  -- GitHub Copilot
  {
    'github/copilot.vim',
    event = 'InsertEnter',
    config = function()
      vim.g.copilot_no_tab_map = true
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

  -- ChatGPT Integration
  {
    'jackMort/ChatGPT.nvim',
    cmd = {
      'ChatGPT',
      'ChatGPTActAs',
      'ChatGPTEditWithInstructions',
    },
    dependencies = {
      'MunifTanjim/nui.nvim',
      'nvim-lua/plenary.nvim',
      'folke/trouble.nvim',
      'nvim-telescope/telescope.nvim',
    },
    config = function()
      require('chatgpt').setup({
        api_key_cmd = 'pass show azure/hypera/oai/idg-dev/token',
        api_host_cmd = 'echo -n ""',
        api_type_cmd = 'echo azure',
        azure_api_base_cmd = 'pass show azure/hypera/oai/idg-dev/base',
        azure_api_engine_cmd = 'pass show azure/hypera/oai/idg-dev/engine',
        azure_api_version_cmd = 'pass show azure/hypera/oai/idg-dev/api-version',
        predefined_chat_gpt_prompts = 'https://raw.githubusercontent.com/julianobarbosa/custom-gpt-prompts/main/prompt.csv',
      })
    end,
  },

  -- Notes and Knowledge Management
  {
    'mickael-menu/zk-nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'neovim/nvim-lspconfig',
      'hrsh7th/cmp-nvim-lsp',
    },
    config = true,
  },
}