-- LSP utility functions for validation and common operations
local M = {}

---Validate if a buffer exists and is valid
---@param buffer number The buffer number to validate
---@return boolean is_valid Whether the buffer is valid
M.is_valid_buffer = function(buffer)
  return buffer and vim.api.nvim_buf_is_valid(buffer)
end

---Validate if a client exists and has required capability
---@param client table The LSP client to validate
---@param capability string The capability to check for
---@return boolean has_capability Whether the client has the required capability
M.has_capability = function(client, capability)
  if not client or not client.server_capabilities then
    return false
  end
  return client.server_capabilities[capability] and true or false
end

---Create a protected call wrapper with error logging
---@param fn function The function to call
---@param error_msg string The error message prefix
---@return boolean success Whether the call succeeded
M.protected_call = function(fn, error_msg)
  local status, err = pcall(fn)
  if not status then
    vim.notify(string.format('%s: %s', error_msg, err), vim.log.levels.WARN)
  end
  return status
end

return M