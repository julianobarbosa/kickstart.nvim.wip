return {
  {
    'mickael-menu/zk-nvim',
    dependencies = {
      'neovim/nvim-lspconfig',
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/cmp-nvim-lsp',
      'folke/neodev.nvim',
    },
    config = function()
      require('mason').setup({
        ui = {
          border = 'rounded',
          icons = {
            package_installed = '✓',
            package_pending = '➜',
            package_uninstalled = '✗'
          }
        },
        log_level = vim.log.levels.INFO,
        max_concurrent_installers = 4,
      })

      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        },
        pyright = {},
        bashls = {},
        dockerls = {},
        terraformls = {},
        yamlls = {},
        ansiblels = {},
        marksman = {},
      }

      -- Ensure the servers are installed
      require('mason-lspconfig').setup({
        ensure_installed = vim.tbl_keys(servers),
        automatic_installation = true,
      })

      -- Setup neovim lua configuration
      --require('neodev').setup()

      -- Combine LSP and nvim-cmp capabilities
      -- Initialize capabilities with proper LSP structures
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      capabilities.textDocument.documentHighlight = {
        dynamicRegistration = true
      }

      -- Configure on_attach function for document highlight
      local on_attach = function(client, bufnr)
        if client.server_capabilities.documentHighlightProvider then
          vim.api.nvim_create_augroup('lsp_document_highlight', { clear = true })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            group = 'lsp_document_highlight',
            buffer = bufnr,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd('CursorMoved', {
            group = 'lsp_document_highlight',
            buffer = bufnr,
            callback = vim.lsp.buf.clear_references,
          })
        end
      end

      -- Setup each language server using the recommended new approach
      local lspconfig = require('lspconfig')
      for server_name, server_config in pairs(servers) do
        local config = {
          capabilities = capabilities,
          on_attach = on_attach,
          settings = server_config.settings,
        }
        lspconfig[server_name].setup(config)
      end
    end,
  },
}
