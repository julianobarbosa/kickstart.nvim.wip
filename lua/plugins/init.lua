--- @file init.lua
--- @brief Plugin management and loading
--- @module plugins

-- [[ Plugin Management ]]

local utils = require('utils')

-- Bootstrap lazy.nvim
local function bootstrap_lazy()
  local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
  if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.notify('Installing lazy.nvim...', vim.log.levels.INFO)
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    local out = vim.fn.system({
      'git',
      'clone',
      '--filter=blob:none',
      '--branch=stable',
      lazyrepo,
      lazypath,
    })
    if vim.v.shell_error ~= 0 then
      error('Error cloning lazy.nvim:\n' .. out)
    end
    vim.notify('lazy.nvim installed successfully!', vim.log.levels.INFO)
  end
  vim.opt.rtp:prepend(lazypath)
end

-- Load plugin specifications
local function load_specs()
  -- Define loading order
  local spec_files = {
    'editor',  -- Core editor enhancements
    'ui',      -- UI components
    'lsp',     -- LSP and completion
    'tools',   -- Development tools
  }

  local specs = {}
  for _, name in ipairs(spec_files) do
    local ok, spec = utils.safe_require('plugins.specs.' .. name)
    if ok then
      -- Each spec file returns a table of plugin specs
      vim.list_extend(specs, spec)
    end
  end

  return specs
end

-- Initialize plugin system
local function setup()
  -- Bootstrap lazy.nvim if needed
  bootstrap_lazy()

  -- Configure lazy.nvim
  require('lazy').setup({
    spec = load_specs(),
    defaults = {
      lazy = true,  -- Default to lazy loading
    },
    install = {
      -- Try to load colorscheme when installing plugins
      colorscheme = { 'tokyonight', 'habamax' },
    },
    ui = {
      -- Use border for lazy.nvim UI
      border = 'rounded',
      icons = {
        cmd = '⌘',
        config = '🛠',
        event = '📅',
        ft = '📂',
        init = '⚙',
        keys = '🔑',
        plugin = '🔌',
        runtime = '💻',
        source = '📄',
        start = '🚀',
        task = '📌',
      },
    },
    performance = {
      cache = {
        enabled = true,
      },
      reset_packpath = true, -- Reset the package path to improve startup time
      rtp = {
        reset = true,        -- Reset the runtime path to improve startup time
        -- Disable some rtp plugins
        disabled_plugins = {
          'gzip',
          'matchit',
          'matchparen',
          'netrwPlugin',
          'tarPlugin',
          'tohtml',
          'tutor',
          'zipPlugin',
        },
      },
    },
    -- Debug startup time
    debug = false,
  })
end

return {
  setup = setup,
  load_specs = load_specs,
}