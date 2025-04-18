--- @file keymaps.lua
--- @brief Core Neovim key mappings
--- @module core.keymaps

-- [[ Core Keymaps Configuration ]]

local M = {}

-- Helper function for setting keymaps
local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.noremap = opts.noremap == nil and true or opts.noremap
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Configure all keymaps
local function setup_keymaps()
  -- [[ Search and Diagnostics ]]
  map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlights' })
  map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

  -- [[ Window Navigation ]]
  map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
  map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
  map('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
  map('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

  -- [[ Buffer Navigation ]]
  map('n', '<S-h>', ':bp<CR>', { desc = 'Go to previous buffer' })
  map('n', '<S-l>', ':bn<CR>', { desc = 'Go to next buffer' })

  -- [[ File Operations ]]
  map('n', '<leader>wa', ':wall<CR>', { desc = '[W]rite [A]ll buffers' })
  map('n', '<leader>wf', ':w<CR>', { desc = '[W]rite current [F]ile' })

  -- [[ Terminal Integration ]]
  map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

  -- [[ System Clipboard Integration ]]
  map('v', '<C-c>', '"+y', { desc = 'Copy to system clipboard' })
  map('n', '<C-v>', '"+p', { desc = 'Paste from system clipboard' })
  map('i', '<C-v>', '<C-r>+', { desc = 'Paste from system clipboard in insert mode' })

  -- [[ Command Mode Aliases ]]
  -- Common command mode typos/aliases
  local command_aliases = {
    qw = 'wq',
    WQ = 'wq',
    QW = 'wq',
  }

  for from, to in pairs(command_aliases) do
    vim.api.nvim_command(string.format('cmap %s %s', from, to))
  end

  -- [[ Terraform Integration ]]
  local terraform_opts = { noremap = true, silent = true }
  map('n', '<leader>ti', ':!make init<CR>', terraform_opts)
  map('n', '<leader>tv', ':!make validate<CR>', terraform_opts)
  map('n', '<leader>tp', ':!make plan<CR>', terraform_opts)
  map('n', '<leader>taa', ':!make applyA<CR>', terraform_opts)
end

function M.setup()
  if not vim then return end
  setup_keymaps()
end

return M
