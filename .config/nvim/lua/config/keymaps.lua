local keymaps = {
  n = {
    ['gn'] = { '<cmd>bprevious<cr>', desc = 'Previous buffer', silent = true },
    ['gm'] = { '<cmd>bprevious<cr>', desc = 'Next buffer', silent = true },
    ['U'] = { '<cmd>redo<cr>', desc = 'Redo' },
    ['<A-d>'] = { '"_d', desc = "Delete, no yank" },
    ['<A-c>'] = { '"_c', desc = "Change, no yank" },
    ['\\'] = { '<cmd>nohls<cr>', desc = 'Clear search query', silent = true }
  }
}

for mode, binds in pairs(keymaps) do
  for bind, data in pairs(binds) do
    local cmd = data[1]
    data[1] = nil
    vim.keymap.set(mode, bind, cmd, data)
  end
end
