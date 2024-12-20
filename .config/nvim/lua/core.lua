return {
  lsps = {
    clangd = {},
    html = {},
    lua_ls = {},
    marksman = {},
    nushell = {},
    pylsp = {},
    rust_analyzer = {},
    texlab = {},
    taplo = {},
    tinymist = {
      single_file_support = true,
      root_dir = function()
        return vim.fn.getcwd()
      end,
      settings = {}
    },
    yamlls = {}
  }
}
