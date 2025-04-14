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

-- Cache for loaded specs
local spec_cache = {}

-- Load plugin specifications with caching and prioritization
local function load_specs()
  -- Define loading priority and timing
  local spec_files = {
    { name = 'editor', priority = 100 },  -- Core editor features load first
    { name = 'ui', priority = 50 },       -- UI components load second
    { name = 'lsp', priority = 25 },      -- LSP loads progressively
    { name = 'tools', priority = 0 },     -- Tools load last
  }

  -- Check cache first
  local cache_file = vim.fn.stdpath('cache') .. '/plugin_specs.lua'
  if vim.fn.filereadable(cache_file) == 1 then
    local cached = loadfile(cache_file)
    if cached then
      local ok, data = pcall(cached)
      if ok and data and data.timestamp and (os.time() - data.timestamp) < 3600 then
        return data.specs
      end
    end
  end

  -- Load and sort specs by priority
  local specs = {}
  for _, file in ipairs(spec_files) do
    if spec_cache[file.name] then
      vim.list_extend(specs, spec_cache[file.name])
    else
      local ok, spec = utils.safe_require('plugins.specs.' .. file.name)
      if ok then
        -- Add priority to each spec
        for _, s in ipairs(spec) do
          s.priority = s.priority or file.priority
        end
        spec_cache[file.name] = spec
        vim.list_extend(specs, spec)
      end
    end
  end

  -- Sort specs by priority
  table.sort(specs, function(a, b)
    return (a.priority or 0) > (b.priority or 0)
  end)

  -- Cache the results
  local file = io.open(cache_file, 'w')
  if file then
    file:write(string.format('return { timestamp = %d, specs = %s }', os.time(), vim.inspect(specs)))
    file:close()
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
        path = vim.fn.stdpath('cache') .. '/lazy/cache',
        -- Only check mtime of files for cache invalidation
        ttl = 3600 * 24,  -- Cache for 24 hours
      },
      reset_packpath = true,
      rtp = {
        reset = true,
        paths = {
          vim.fn.stdpath('data') .. '/lazy',
          vim.fn.stdpath('config'),
        },
        -- Disable non-essential rtp plugins for faster startup
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