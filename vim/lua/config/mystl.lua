-- 自实现的简易状态栏
local M = {}

-- stylua: ignore
M.mode_table = {
  ['n']     = 'NORMAL',
  ['no']    = 'O-PENDING',
  ['nov']   = 'O-PENDING',
  ['noV']   = 'O-PENDING',
  ['no\22'] = 'O-PENDING',
  ['niI']   = 'NORMAL',
  ['niR']   = 'NORMAL',
  ['niV']   = 'NORMAL',
  ['nt']    = 'NORMAL',
  ['ntT']   = 'NORMAL',
  ['v']     = 'VISUAL',
  ['vs']    = 'VISUAL',
  ['V']     = 'V-LINE',
  ['Vs']    = 'V-LINE',
  ['\22']   = 'V-BLOCK',
  ['\22s']  = 'V-BLOCK',
  ['s']     = 'SELECT',
  ['S']     = 'S-LINE',
  ['\19']   = 'S-BLOCK',
  ['i']     = 'INSERT',
  ['ic']    = 'INSERT',
  ['ix']    = 'INSERT',
  ['R']     = 'REPLACE',
  ['Rc']    = 'REPLACE',
  ['Rx']    = 'REPLACE',
  ['Rv']    = 'V-REPLACE',
  ['Rvc']   = 'V-REPLACE',
  ['Rvx']   = 'V-REPLACE',
  ['c']     = 'COMMAND',
  ['cv']    = 'EX',
  ['ce']    = 'EX',
  ['r']     = 'REPLACE',
  ['rm']    = 'MORE',
  ['r?']    = 'CONFIRM',
  ['!']     = 'SHELL',
  ['t']     = 'TERMINAL',
}

-- MyStatusLine, 简易实现以提高载入速度 {{{
local function create_transitional_hl(left, right)
  local target_name = left .. '_' .. right
  local name = left
  local opts = vim.api.nvim_get_hl(0, { name = name, link = false })
  if not vim.tbl_isempty(vim.api.nvim_get_hl(0, { name = target_name })) then
    return false -- 已存在的话就忽略
  end
  if vim.tbl_isempty(opts) then
    return false
  end
  local right_opts = vim.api.nvim_get_hl(0, { name = right, link = false })
  opts = vim.tbl_deep_extend('force', opts, { reverse = not opts.reverse, fg = right_opts.bg or 'NONE' })
  vim.api.nvim_set_hl(0, target_name, opts) ---@diagnostic disable-line
  return true
end

local function create_reverse_hl(name)
  local target_name = name .. 'Reverse'
  if not vim.tbl_isempty(vim.api.nvim_get_hl(0, { name = target_name })) then
    return false -- 已存在的话就忽略
  end
  local opts = vim.api.nvim_get_hl(0, { name = name, link = false })
  if vim.tbl_isempty(opts) then
    return false
  end
  opts = vim.tbl_deep_extend('force', opts, { reverse = not opts.reverse })
  vim.api.nvim_set_hl(0, target_name, opts) ---@diagnostic disable-line
  return true
end

local function status_line_theme_gruvbox() ---@diagnostic disable-line
  vim.api.nvim_set_hl(0, 'MyStlNormal', { fg = '#a89984', bg = '#504945' })      -- 246 239
  vim.api.nvim_set_hl(0, 'MyStlNormalNC', { fg = '#7c6f64', bg = '#3c3836' })    -- 243 237
  vim.api.nvim_set_hl(0, 'MyStlNormalMode', { fg = '#282828', bg = '#a89984' })  -- 235 246
  vim.api.nvim_set_hl(0, 'MyStlInsertMode', { fg = '#282828', bg = '#83a598' })  -- 235 109
  vim.api.nvim_set_hl(0, 'MyStlVisualMode', { fg = '#282828', bg = '#fe8019' })  -- 235 208
  vim.api.nvim_set_hl(0, 'MyStlReplaceMode', { fg = '#282828', bg = '#8ec07c' }) -- 235 108
  create_transitional_hl('MyStlNormal', 'Normal')
  create_transitional_hl('MyStlNormalNC', 'Normal')
end

local function status_line_theme_mywombat()
  vim.api.nvim_set_hl(0, 'MyStlNormal', { fg = '#282828', bg = '#8ac6f2', ctermfg = 235, ctermbg = 117 })
  vim.api.nvim_set_hl(0, 'MyStlNormalNC', { fg = '#303030', bg = '#6a6a6a', ctermfg = 236, ctermbg = 242 })
  vim.api.nvim_set_hl(0, 'MyStlNormalMode', { fg = '#282828', bg = '#eeee00', ctermfg = 235, ctermbg = 226, bold = true })
  vim.api.nvim_set_hl(0, 'MyStlInsertMode', { fg = '#282828', bg = '#95e454', ctermfg = 235, ctermbg = 119, bold = true })
  vim.api.nvim_set_hl(0, 'MyStlVisualMode', { fg = '#282828', bg = '#f2c68a', ctermfg = 235, ctermbg = 216, bold = true })
  vim.api.nvim_set_hl(0, 'MyStlReplaceMode',
    { fg = '#282828', bg = '#e5786d', ctermfg = 235, ctermbg = 203, bold = true })
  create_transitional_hl('MyStlNormal', 'Normal')
  create_transitional_hl('MyStlNormalNC', 'Normal')
  create_transitional_hl('MyStlNormal', 'MyStlNormalMode')
  create_reverse_hl('MyStlNormalMode')
  create_reverse_hl('MyStlInsertMode')
  create_reverse_hl('MyStlVisualMode')
  create_reverse_hl('MyStlReplaceMode')
  create_reverse_hl('MyStlNormalNC')

  -- gruvbox.nvim 的这几个配色要覆盖掉
  local names = { 'GruvboxRedSign', 'GruvboxGreenSign', 'GruvboxYellowSign', 'GruvboxBlueSign', 'GruvboxPurpleSign',
    'GruvboxAquaSign', 'GruvboxOrangeSign' }
  for _, name in ipairs(names) do
    local opts = vim.api.nvim_get_hl(0, { name = name, link = false })
    if not vim.tbl_isempty(opts) then
      opts.bg = nil
      vim.api.nvim_set_hl(0, name, opts) ---@diagnostic disable-line
    end
  end
  -- 修改 treesiter 部分配色
  vim.api.nvim_set_hl(0, '@variable', {})
  vim.api.nvim_set_hl(0, '@constructor', { link = '@function' })
  vim.api.nvim_set_hl(0, 'markdownCodeBlock', { link = 'markdownCode' })
  vim.api.nvim_set_hl(0, 'markdownCode', { link = 'String' })
  vim.api.nvim_set_hl(0, 'markdownCodeDelimiter', { link = 'Delimiter' })
  vim.api.nvim_set_hl(0, 'markdownOrderedListMarker', { link = 'markdownListMarker' })
  vim.api.nvim_set_hl(0, 'markdownListMarker', { link = 'Tag' })
end

local stl_hl_map = {
  I       = 'MyStlInsertMode',
  T       = 'MyStlInsertMode',
  V       = 'MyStlVisualMode',
  S       = 'MyStlVisualMode',
  R       = 'MyStlReplaceMode',
  ['\22'] = 'MyStlVisualMode',
  ['\19'] = 'MyStlVisualMode',
}
local mode_table = M.mode_table
--  
local head_glyph = require('utils').only_ascii() and '' or ''
local tail_glyph = require('utils').only_ascii() and '' or ''
function MyStatusLine()
  local m = vim.api.nvim_get_mode().mode
  local mode = 'NORMAL'
  if m ~= 'n' then
    mode = mode_table[m] or m:upper()
  end
  local active = tonumber(vim.g.actual_curwin) == vim.api.nvim_get_current_win()
  local mod = vim.o.modified and ' [+]' or ''
  if active then
    local mode_group = stl_hl_map[m:upper():sub(1, 1)] or 'MyStlNormalMode'
    local head_string = string.format('%%#%s#%s', mode_group .. 'Reverse', head_glyph)
    local mode_string = string.format('%%#%s# %s ', mode_group, mode)
    local file_string = string.format('%%#%s# %%f%s │ %%l/%%L,%%v ', 'MyStlNormal', mod)
    local tail_string = string.format('%%#%s#%s%%#StatusLine#', 'MyStlNormal_Normal', tail_glyph)
    return head_string .. mode_string .. file_string .. tail_string
  else
    local head_string = string.format('%%#%s#%s', 'MyStlNormalNCReverse', head_glyph)
    local file_string = string.format('%%#%s# %%f%s │ %%l/%%L,%%v ', 'MyStlNormalNC', mod)
    local tail_string = string.format('%%#%s#%s%%#StatusLine#', 'MyStlNormalNC_Normal', tail_glyph)
    return head_string .. file_string .. tail_string
  end
end

-- init MyStatusLine
local mystl_theme = status_line_theme_mywombat
mystl_theme()
vim.api.nvim_create_autocmd('ColorScheme', { callback = mystl_theme })
vim.opt.showmode = false
vim.opt.statusline = '%{%v:lua.MyStatusLine()%}'
-- :pwd<CR> 的时候会不及时刷新, 所以需要添加这个自动命令
vim.api.nvim_create_autocmd('ModeChanged', { callback = function() vim.cmd.redrawstatus() end })
-- 修正 quickfix 窗口的状态栏
vim.api.nvim_create_autocmd('BufReadPost', {
  callback = function()
    local stl = vim.opt_local.statusline:get() ---@diagnostic disable-line: undefined-field
    if stl ~= '' and stl ~= '─' then
      vim.opt_local.statusline = ''
    end
  end
})
-- }}}

return M
