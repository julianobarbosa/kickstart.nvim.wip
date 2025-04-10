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
      local lspconfig = require('lspconfig')
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
      -- Initialize capabilities with proper LSP structures and explicit documentHighlight support
      local capabilities = vim.tbl_deep_extend('force',
        require('cmp_nvim_lsp').default_capabilities(),
        {
          textDocument = {
            documentHighlight = {
              dynamicRegistration = true
            }
          }
        }
      )

      -- Configure on_attach function for document highlight with proper capability checking
      local on_attach = function(client, bufnr)
        -- Check if the LSP server supports document highlighting
        if client.supports_method('textDocument/documentHighlight') then
          local group = vim.api.nvim_create_augroup('lsp_document_highlight', { clear = true })

          -- Set up autocommands for document highlighting
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            group = group,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.document_highlight()
            end,
          })

          vim.api.nvim_create_autocmd('CursorMoved', {
            group = group,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.clear_references()
            end,
          })
        end
      end

      -- Setup each language server using the recommended new approach
      for server_name, server_config in pairs(servers) do
        local config = {
          capabilities = capabilities,
          on_attach = on_attach,
          settings = server_config.settings,
        }
        lspconfig[server_name].setup(config)
      end

      -- Disable document highlight in Fugitive commit buffers
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'gitcommit',
        callback = function(args)
          local bufnr = args.buf
          vim.api.nvim_create_autocmd({'CursorHold', 'CursorHoldI', 'CursorMoved'}, {
            buffer = bufnr,
            callback = function()
              -- Override highlight and clear to no-ops
              vim.lsp.buf.document_highlight = function() end
              vim.lsp.buf.clear_references = function() end
            end,
          })
        end,
      })
    end,
  }
}
