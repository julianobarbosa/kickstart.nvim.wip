--- @file options.lua
--- @brief Core Neovim options and settings
--- @module core.options

-- [[ Core Vim Options ]]

local function setup_options()
  -- Editor Display
  vim.opt.number = true          -- Enable line numbers
  vim.opt.relativenumber = true  -- Enable relative line numbers for easier navigation
  vim.opt.signcolumn = 'yes'    -- Always show the signcolumn
  vim.opt.cursorline = true     -- Highlight current line
  vim.opt.showmode = false      -- Don't show mode in command line (status line will show it)
  vim.opt.scrolloff = 10        -- Minimal screen lines around cursor

  -- Whitespace Visualization
  vim.opt.list = true
  vim.opt.listchars = {
    tab = '» ',
    trail = '·',
    nbsp = '␣'
  }

  -- Indentation and Wrapping
  vim.opt.breakindent = true    -- Enable break indent
  vim.opt.splitright = true     -- New vertical splits to the right
  vim.opt.splitbelow = true     -- New horizontal splits below

  -- Search and Replace
  vim.opt.ignorecase = true     -- Case-insensitive search...
  vim.opt.smartcase = true      -- ...unless \C or capital in search
  vim.opt.inccommand = 'split'  -- Live preview for substitutions

  -- Editor Behavior
  vim.opt.mouse = 'a'           -- Enable mouse for all modes
  vim.opt.updatetime = 250      -- Faster completion
  vim.opt.timeoutlen = 300      -- Shorter key sequence timeout
  vim.opt.undofile = true       -- Persistent undo history

  -- OS Integration
  -- Schedule clipboard setting to reduce startup time
  vim.schedule(function()
    vim.opt.clipboard = 'unnamedplus'  -- Sync with system clipboard
  end)
end

-- Initialize options
setup_options()

-- Return the module
return {
  setup = setup_options
}
