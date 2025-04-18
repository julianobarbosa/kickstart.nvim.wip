--- @file autocmds.lua
--- @brief Core autocommands configuration
--- @module core.autocmds

local M = {}

-- [[ Autocommands Configuration ]]
local function setup_autocommands()
  -- Highlight on yank
  vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
    callback = function()
      vim.highlight.on_yank()
    end,
  })

  -- LSP Document Highlight
  local highlight_group = vim.api.nvim_create_augroup('lsp-document-highlight', { clear = true })

  -- Create autocommands for LSP document highlighting
  local function setup_document_highlight(client, bufnr)
    if client and client.supports_method('textDocument/documentHighlight') then
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = bufnr,
        group = highlight_group,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = bufnr,
        group = highlight_group,
        callback = vim.lsp.buf.clear_references,
      })
    end
  end

  -- LSP attach/detach handling
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp-attach-configure', { clear = true }),
    callback = function(event)
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      setup_document_highlight(client, event.buf)
    end,
  })

  vim.api.nvim_create_autocmd('LspDetach', {
    group = vim.api.nvim_create_augroup('lsp-detach-cleanup', { clear = true }),
    callback = function(event)
      vim.lsp.buf.clear_references()
      vim.api.nvim_clear_autocmds({ group = 'lsp-document-highlight', buffer = event.buf })
    end,
  })
end

function M.setup()
  setup_autocommands()
end

return M
