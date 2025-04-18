--- @file tools.lua
--- @brief Development tools and debugging plugins specification
--- @module plugins.specs.tools

-- [[ Development Tools and Debugging ]]

return {
  -- Debugging support
  {
    'mfussenegger/nvim-dap',
    event = 'VeryLazy',
    dependencies = {
      -- Debugger UI
      {
        'rcarriga/nvim-dap-ui',
        dependencies = { 'nvim-neotest/nvim-nio' },
        config = function()
          local dapui = require('dapui')
          dapui.setup({
            icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
            controls = {
              icons = {
                pause = '⏸',
                play = '▶',
                step_into = '⏎',
                step_over = '⏭',
                step_out = '⏮',
                step_back = 'b',
                run_last = '▶▶',
                terminate = '⏹',
                disconnect = '⏏',
              },
            },
          })

          local dap = require('dap')
          dap.listeners.after.event_initialized['dapui_config'] = dapui.open
          dap.listeners.before.event_terminated['dapui_config'] = dapui.close
          dap.listeners.before.event_exited['dapui_config'] = dapui.close
        end,
      },

      -- Virtual text for debug points
      'theHamsta/nvim-dap-virtual-text',

      -- Mason integration
      'williamboman/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',

      -- Language debuggers
      'leoluz/nvim-dap-go',
      'mfussenegger/nvim-dap-python',
    },
    keys = {
      { '<F5>', function() require('dap').continue() end, desc = 'Debug: Start/Continue' },
      { '<F1>', function() require('dap').step_into() end, desc = 'Debug: Step Into' },
      { '<F2>', function() require('dap').step_over() end, desc = 'Debug: Step Over' },
      { '<F3>', function() require('dap').step_out() end, desc = 'Debug: Step Out' },
      { '<leader>b', function() require('dap').toggle_breakpoint() end, desc = 'Debug: Toggle Breakpoint' },
      { '<leader>B', function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = 'Debug: Set Breakpoint' },
      { '<F7>', function() require('dapui').toggle() end, desc = 'Debug: Toggle UI' },
    },
    config = function()
      -- Configure mason-nvim-dap
      require('mason-nvim-dap').setup({
        automatic_installation = true,
        automatic_setup = true,
        handlers = {},
        ensure_installed = {
          'delve',
          'debugpy',
          'python',
        },
      })

      -- Python setup
      require('dap-python').setup(vim.fn.exepath('python3'))

      -- Go setup
      require('dap-go').setup({
        delve = {
          -- Windows-specific configuration
          detached = vim.fn.has('win32') == 0,
        },
      })
    end,
  },

  -- Auto-formatting
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format({ async = true, lsp_fallback = true })
        end,
        desc = 'Format buffer',
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'isort', 'black' },
        javascript = { { 'prettierd', 'prettier' } },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    },
  },

  -- Code linting
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('lint').linters_by_ft = {
        python = { 'ruff', 'mypy' },
        javascript = { 'eslint' },
        typescript = { 'eslint' },
        terraform = { 'tflint' },
        yaml = { 'yamllint' },
      }

      vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost', 'InsertLeave' }, {
        group = vim.api.nvim_create_augroup('lint_autocmds', { clear = true }),
        callback = function()
          require('lint').try_lint()
        end,
      })
    end,
  },
}
