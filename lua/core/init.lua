--- @file init.lua
--- @brief Core configuration initialization
--- @module core.init

-- [[ Core Configuration ]]

local M = {}

-- Initialize runtime paths
local function setup_runtime_paths()
  local rtp = vim.opt.runtimepath:get()
  local nvim_share_path = '/usr/share/nvim'
  if vim.fn.isdirectory(nvim_share_path) == 1 and not vim.tbl_contains(rtp, nvim_share_path) then
    vim.opt.runtimepath:append(nvim_share_path)
  end
end

-- Initialize directories
local function setup_directories()
  -- Create syntax directory if it doesn't exist
  local syntax_dir = vim.fn.stdpath('config') .. '/syntax'
  if vim.fn.isdirectory(syntax_dir) == 0 then
    vim.fn.mkdir(syntax_dir, 'p')

    -- Create minimal syntax.vim if it doesn't exist
    local syntax_file = syntax_dir .. '/syntax.vim'
    if vim.fn.filereadable(syntax_file) == 0 then
      local file = io.open(syntax_file, 'w')
      if file then
        file:write('" Base syntax file\n')
        file:close()
      end
    end
  end

  -- Set up swap directory
  local swap_dir = vim.fn.stdpath('data') .. '/swap'
  if vim.fn.isdirectory(swap_dir) == 0 then
    vim.fn.mkdir(swap_dir, 'p')
  end
end

-- Initialize core leader settings
local function setup_leader()
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '
end

-- Initialize core settings
function M.setup()
  -- Early setup
  setup_runtime_paths()
  setup_directories()
  setup_leader()

  -- Set up core modules
  require('core.options').setup()
  require('core.keymaps').setup()
  require('core.autocmds').setup()
end

return M
