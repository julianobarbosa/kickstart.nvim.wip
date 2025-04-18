-- LSP configuration and setup
local servers = require('custom.plugins.lsp.servers')
local highlight = require('custom.plugins.lsp.highlight')

return {
  {
    'mickael-menu/zk-nvim',
    dependencies = {
      'neovim/nvim-lspconfig',
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      -- Initialize LSP components
      local lspconfig = require('lspconfig')
      
      -- Set up Mason package manager
      require('mason').setup(servers.mason_config)

      -- Set up Mason-LSPConfig integration
      require('mason-lspconfig').setup(servers.mason_lspconfig)

      -- Initialize capabilities with LSP and nvim-cmp defaults
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- Set up minimal on_attach (highlighting handled separately)
      local on_attach = function(client, bufnr)
        -- Empty on_attach as document highlighting is now handled by LspAttach
      end

      -- Set up highlighting
      highlight.setup()

      -- Disable highlighting for gitcommit files
      highlight.disable_for_filetype('gitcommit')

      -- Setup each language server
      for server_name, server_config in pairs(servers.configs) do
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