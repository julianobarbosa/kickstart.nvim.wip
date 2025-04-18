--- @file editor.lua
--- @brief Editor enhancement plugins specification
--- @module plugins.specs.editor

-- [[ Editor Enhancement Plugins ]]

return {
  -- Auto-pairs for brackets, quotes, etc.
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    dependencies = { 'hrsh7th/nvim-cmp' },
    config = function()
      require('nvim-autopairs').setup({})
      -- Add parentheses after function completion
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      local cmp = require('cmp')
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
    end,
  },

  -- Indentation guides
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {},
  },

  -- File tree explorer
  {
    'nvim-neo-tree/neo-tree.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    opts = {
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
    },
  },

  -- Quick file navigation
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = true,
  },

  -- Smart yanking
  {
    'ibhagwan/smartyank.nvim',
    event = 'VeryLazy',
    opts = {},
  },

  -- Code documentation generation
  {
    'danymat/neogen',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    config = true,
  },

  -- Markdown enhancements
  {
    'preservim/vim-markdown',
    ft = 'markdown',
    dependencies = 'godlygeek/tabular',
  },
  {
    'jbyuki/markdown-toggle.nvim',
    ft = 'markdown',
    config = true,
  },

  -- Python f-strings support
  {
    'roojs/f-strings.nvim',
    ft = 'python',
    config = true,
  },
}
