-- LSP document highlighting functionality
local utils = require('custom.plugins.lsp.utils')

local M = {}

---Set up document highlighting for a specific buffer and client
---@param client table The LSP client
---@param buffer number The buffer number
local function setup_buffer_highlighting(client, buffer)
  -- Early return if buffer or client is invalid
  if not utils.is_valid_buffer(buffer) or not client then
    return
  end

  -- Check for document highlight capability
  if not utils.has_capability(client, 'documentHighlightProvider') then
    vim.notify(
      string.format("LSP server '%s' does not support document highlighting", client.name),
      vim.log.levels.DEBUG
    )
    return
  end

  -- Create a unique highlight group for this buffer
  local highlight_group = vim.api.nvim_create_augroup('lsp_document_highlight_' .. buffer, { clear = true })

  -- Set up cursor hold events for highlighting
  vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
    group = highlight_group,
    buffer = buffer,
    callback = function()
      if not utils.is_valid_buffer(buffer) or not client.attached_buffers[buffer] then
        return
      end
      utils.protected_call(
        vim.lsp.buf.document_highlight,
        'Error in document highlight'
      )
    end,
  })

  -- Set up cursor moved event for clearing highlights
  vim.api.nvim_create_autocmd('CursorMoved', {
    group = highlight_group,
    buffer = buffer,
    callback = function()
      if not utils.is_valid_buffer(buffer) or not client.attached_buffers[buffer] then
        return
      end
      utils.protected_call(
        vim.lsp.buf.clear_references,
        'Error clearing document highlights'
      )
    end,
  })
end

---Set up document highlighting via LspAttach event
M.setup = function()
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp_document_highlight', { clear = true }),
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      setup_buffer_highlighting(client, args.buf)
    end,
  })
end

---Disable highlighting for specific filetypes
---@param filetype string The filetype to disable highlighting for
M.disable_for_filetype = function(filetype)
  vim.api.nvim_create_autocmd('FileType', {
    pattern = filetype,
    callback = function(args)
      local bufnr = args.buf
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI', 'CursorMoved' }, {
        buffer = bufnr,
        callback = function()
          -- Override highlight and clear to no-ops
          vim.lsp.buf.document_highlight = function() end
          vim.lsp.buf.clear_references = function() end
        end,
      })
    end,
  })
end

return M
