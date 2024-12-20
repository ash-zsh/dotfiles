return {
  {
    'nvim-telescope/telescope.nvim',
    -- Only one tag exists
    version = false,
    dependencies = {
      { 'nvim-lua/plenary.nvim',                 lazy = true },
      { 'natecraddock/telescope-zf-native.nvim', lazy = true }
    },
    lazy = true,
    config = function()
      local telescope = require('telescope')

      telescope.setup({
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_cursor()
          }
        }
      })
      telescope.load_extension("zf-native")
    end,
    keys = {
      { "<leader>f", "<cmd>Telescope find_files<cr>",      desc = "Find Files" },
      { "<leader>/", "<cmd>Telescope live_grep<cr>",       desc = "Live Grep" },
      { "<leader>b", "<cmd>Telescope buffers<cr>",         desc = "Buffers" },
      { "<leader>d", "<cmd>Telescope diagnostics<cr>",     desc = "Diagnostics" },
      { "gd",        "<cmd>Telescope lsp_definitions<cr>", desc = "Definitions" },
      { "gr",        "<cmd>Telescope lsp_references<cr>",  desc = "References" },
    }
  },
  {
    'nvim-telescope/telescope-ui-select.nvim',
    dependencies = {
      { 'nvim-telescope/telescope.nvim', lazy = true }
    },
    lazy = true,
    config = function()
      require('telescope').load_extension('ui-select')
    end,
    keys = {
      { '<leader>a', function() vim.lsp.buf.code_action() end, desc = "Code Actions" }
    }
  },
  { 'unblevable/quick-scope' }
}
