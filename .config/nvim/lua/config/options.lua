local opts = {
  background = 'light',

  tabstop = 2,
  shiftwidth = 2,
  expandtab = true,

  showmode = false,
  clipboard = 'unnamedplus',

  nu = true,
  rnu = true,
}

for name, value in pairs(opts) do
  vim.opt[name] = value
end
