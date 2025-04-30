-- LSP server configurations
local M = {}

-- Server-specific settings and configurations
M.configs = {
  lua_ls = {
    settings = {
      Lua = {
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  },
  pyright = {},
  ruff = {},
  bashls = {},
  terraformls = {},
  yamlls = {},
  powershell_es = {},
}

-- Mason setup configuration
M.mason_config = {
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
  PATH = 'prepend',
}

-- Mason-lspconfig setup configuration
M.mason_lspconfig = {
  ensure_installed = vim.tbl_keys(M.configs),
  automatic_installation = true,
}

return M
