--- @file init.lua
--- @brief Shared utility functions
--- @module utils

local M = {}

--- Check if a program is executable in the system PATH
-- @param cmd string: The command to check
-- @return boolean: True if executable, false otherwise
function M.is_executable(cmd)
  return vim.fn.executable(cmd) == 1
end

--- Get a valid Python interpreter path
-- @return string: Path to Python interpreter
function M.get_python_path()
  -- Try environment variable first
  local py_env = os.getenv('PYENV_ROOT')
  if py_env then
    local py_path = py_env .. '/versions/3.11.9/bin/python'
    if vim.fn.filereadable(py_path) == 1 then
      return py_path
    end
  end

  -- Fallback to system python3
  return vim.fn.exepath('python3')
end

--- Safely require a module
-- @param module string: Module name to require
-- @return table|nil, error: The module if successful, nil and error otherwise
function M.safe_require(module)
  local ok, result = pcall(require, module)
  if not ok then
    vim.notify(string.format('Error requiring %s: %s', module, result), vim.log.levels.ERROR)
    return nil, result
  end
  return result
end

--- Create an augroup with error handling
-- @param name string: Group name
-- @param opts table: Options for the group
-- @return number: Augroup ID
function M.create_augroup(name, opts)
  opts = opts or { clear = true }
  return vim.api.nvim_create_augroup(name, opts)
end

--- Set a keymap with error handling
-- @param mode string: Mode for the mapping
-- @param lhs string: Left hand side of the mapping
-- @param rhs string|function: Right hand side of the mapping
-- @param opts table: Options for the mapping
function M.map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.noremap = opts.noremap == nil and true or opts.noremap

  local status, error = pcall(vim.keymap.set, mode, lhs, rhs, opts)
  if not status then
    vim.notify(string.format('Error setting keymap %s: %s', lhs, error), vim.log.levels.ERROR)
  end
end

--- Merge two or more tables
-- @param ... table: Tables to merge
-- @return table: Merged table
function M.tbl_deep_extend(...)
  return vim.tbl_deep_extend('force', ...)
end

return M
