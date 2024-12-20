local colors = {
  pure = '#f9f9f9',

  white = '#deebf3',
  grey = '#E3E9EF',
  black = '#2d090b',

  red = '#fb2340',
  orange = '#d17b18',
  green = '#799A18',
  blue = '#4098FD'
}

local theme = {
  normal = {
    a = { fg = colors.black, bg = colors.grey },
    b = { fg = colors.black, bg = colors.grey },
  },
  insert = { a = { fg = colors.pure, bg = colors.orange } },
  visual = { a = { fg = colors.pure, bg = colors.black } },
  replace = { a = { fg = colors.pure, bg = colors.red } },
}

local static_grey = {
  fg = colors.black,
  bg = colors.grey
}


local empty = require('lualine.component'):extend()
function empty:draw(default_highlight)
  self.status = ''
  self.applied_separator = ''
  self:apply_highlights(default_highlight)
  self:apply_section_separators()
  return self.status
end

-- Put proper separators and gaps between components in sections
local function process_sections(sections)
  for name, section in pairs(sections) do
    local left = name:sub(9, 10) < 'x'
    for pos = 1, name ~= 'lualine_z' and #section or #section - 1 do
      table.insert(section, pos * 2, { empty, color = { fg = colors.pure, bg = colors.pure } })
    end
    for id, comp in ipairs(section) do
      if type(comp) ~= 'table' then
        comp = { comp }
        section[id] = comp
      end
      comp.separator = left and { right = '' } or { left = '' }
    end
  end
  return sections
end

local function search_result()
  if vim.v.hlsearch == 0 then
    return ''
  end
  local last_search = vim.fn.getreg('/')
  if not last_search or last_search == '' then
    return ''
  end
  local searchcount = vim.fn.searchcount { maxcount = 9999 }
  return last_search .. '(' .. searchcount.current .. '/' .. searchcount.total .. ')'
end

local function modified()
  if vim.bo.modified then
    return '+'
  elseif vim.bo.modifiable == false or vim.bo.readonly == true then
    return '-'
  end
  return ''
end

require('lualine').setup {
  options = {
    theme = theme,
    component_separators = '',
    section_separators = { left = '', right = '' },
  },
  sections = process_sections {
    lualine_a = { 'mode' },
    lualine_b = {
      'branch',
      'diff',
      {
        'diagnostics',
        source = { 'nvim' },
        sections = { 'error' },
        diagnostics_color = { error = { bg = colors.blue, fg = colors.white } },
      },
      {
        'diagnostics',
        source = { 'nvim' },
        sections = { 'warn' },
        diagnostics_color = { warn = { bg = colors.green, fg = colors.white } },
      },
      {
        modified,
        color = {
          fg = colors.pure,
          bg = colors.red
        }
      },
      {
        '%w',
        cond = function()
          return vim.wo.previewwindow
        end,
      },
      {
        '%r',
        cond = function()
          return vim.bo.readonly
        end,
      },
      {
        '%q',
        cond = function()
          return vim.bo.buftype == 'quickfix'
        end,
      },
    },
    lualine_c = {},
    lualine_x = {},
    lualine_y = {
      {
        '',
        color = {
          fg = colors.pure,
          bg = colors.pure,
        }
      }
    },
    lualine_z = {
      { search_result,   color = static_grey },
      { '%l:%c %p%%/%L', color = static_grey },
      { 'filename',      file_status = false, path = 1 },
    }
  }
}
