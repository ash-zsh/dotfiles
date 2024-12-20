local core = require('core')

return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- ~1000 commits since last tag
    version = false,
    commit = "48fc5d1dfe3dded8028826dfee7526e26212c73b",
    event = 'VeryLazy',
    build = ":TSUpdate",
    dependencies = {
      { "nushell/tree-sitter-nu", build = ":TSUpdate nu" },
    },
    config = function()
      local configs = require("nvim-treesitter.configs")

      configs.setup({
        ensure_installed = {
          "c", "rust",
          "bash", "make",
          "lua", "vim", "vimdoc", "query",
          "css", "javascript", "html", "php",
          "json", "toml", "xml", "yaml",
          "markdown",
          "csv", "psv", "tsv"
        },
        sync_install = false,
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "vnv",
            node_incremental = "vnn",
            node_decremental = "vnN"
          }
        }
      })
    end
  },
  {
    'neovim/nvim-lspconfig',
    event = 'VeryLazy',
    config = function()
      local conf = require('lspconfig')

      for lsp, opts in pairs(core.lsps) do
        conf[lsp].setup(opts)
      end
    end,
  },
  { 'echasnovski/mini.pairs', opts = {} },
  {
    'saecki/live-rename.nvim',
    event = 'VeryLazy',
    lazy = true,
    keys = {
      { '<leader>r', function() require('live-rename').rename() end,                             desc = 'Rename Symbol' },
      { '<leader>R', function() require('live-rename').rename({ text = "", insert = true }) end, desc = 'Change Symbol' }
    }
  }
}
