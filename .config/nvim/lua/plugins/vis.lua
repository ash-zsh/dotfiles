return {
  {
    'sainnhe/edge',
    priority = 1000,
    config = function()
      vim.g.edge_enable_italic = true
      vim.cmd.colorscheme('edge')
    end
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine.themes.faith')
    end
  },
  'lewis6991/gitsigns.nvim',
  {
    "folke/which-key.nvim",
    lazy = false,
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    ---@module "ibl"
    ---@type ibl.config
    opts = {},
  },
}
