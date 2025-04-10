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

      -- Initialize capabilities with LSP and nvim-cmp defaults
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- Configure on_attach function (minimal version since highlighting is handled by LspAttach)
      local on_attach = function(client, bufnr)
        -- Empty on_attach as document highlighting is now handled by LspAttach
      end

      -- Set up document highlighting via LspAttach
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp_document_highlight', { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          local buffer = args.buf

          -- Validate buffer and client
          if not (buffer and vim.api.nvim_buf_is_valid(buffer) and client) then
            return
          end

          -- Check for required capabilities using proper LSP protocol methods
          local capabilities = client.server_capabilities
          if not capabilities or not capabilities.documentHighlightProvider then
            vim.notify(string.format(
              "LSP server '%s' does not support document highlighting",
              client.name
            ), vim.log.levels.DEBUG)
            return
          end

          -- Set up highlighting with error handling
          local highlight_group = vim.api.nvim_create_augroup('lsp_document_highlight_' .. buffer, { clear = true })

          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            group = highlight_group,
            buffer = buffer,
            callback = function()
              -- Validate both buffer and client still exist
              if not (buffer and vim.api.nvim_buf_is_valid(buffer) and client.attached_buffers[buffer]) then
                return
              end

              -- Protected call for document highlight
              local status, err = pcall(vim.lsp.buf.document_highlight)
              if not status then
                vim.notify(string.format(
                  "Error in document highlight: %s",
                  err
                ), vim.log.levels.WARN)
              end
            end,
          })

          vim.api.nvim_create_autocmd('CursorMoved', {
            group = highlight_group,
            buffer = buffer,
            callback = function()
              -- Validate both buffer and client still exist
              if not (buffer and vim.api.nvim_buf_is_valid(buffer) and client.attached_buffers[buffer]) then
                return
              end

              -- Protected call for clearing references
              local status, err = pcall(vim.lsp.buf.clear_references)
              if not status then
                vim.notify(string.format(
                  "Error clearing document highlights: %s",
                  err
                ), vim.log.levels.WARN)
              end
            end,
          })
        end,
      })

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
