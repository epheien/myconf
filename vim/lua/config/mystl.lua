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

-- 使用 left 的 bg 和 right 的 fg 组成新的高亮组, 如果 reverse 传入, 则再 reverse
local function create_transitional_hl(left, right, reverse)
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
  opts = vim.tbl_deep_extend('force', opts, { fg = right_opts.bg or 'NONE' })
  if reverse then
    opts.reverse = not opts.reverse
  end
  vim.api.nvim_set_hl(0, target_name, opts) ---@diagnostic disable-line
  return true
end

local function post_process_status_line_theme()
  create_transitional_hl('MyStlNormal', 'Normal', true)
  create_transitional_hl('MyStlNormalNC', 'Normal', true)
  create_transitional_hl('Normal', 'MyStlNormalMode')
  create_transitional_hl('Normal', 'MyStlCommandMode')
  create_transitional_hl('Normal', 'MyStlInsertMode')
  create_transitional_hl('Normal', 'MyStlVisualMode')
  create_transitional_hl('Normal', 'MyStlReplaceMode')
  create_transitional_hl('Normal', 'MyStlNormalNC')
end

-- stylua: ignore
local function status_line_theme_gruvbox() ---@diagnostic disable-line
  vim.api.nvim_set_hl(0, 'MyStlNormal', { fg = '#a89984', bg = '#504945' })      -- 246 239
  vim.api.nvim_set_hl(0, 'MyStlNormalNC', { fg = '#7c6f64', bg = '#3c3836' })    -- 243 237
  vim.api.nvim_set_hl(0, 'MyStlNormalMode', { fg = '#282828', bg = '#a89984' })  -- 235 246
  vim.api.nvim_set_hl(0, 'MyStlInsertMode', { fg = '#282828', bg = '#83a598' })  -- 235 109
  vim.api.nvim_set_hl(0, 'MyStlVisualMode', { fg = '#282828', bg = '#fe8019' })  -- 235 208
  vim.api.nvim_set_hl(0, 'MyStlReplaceMode', { fg = '#282828', bg = '#8ec07c' }) -- 235 108
  vim.api.nvim_set_hl(0, 'MyStlCommandMode', { link = 'MyStlNormalMode', default = true })
  post_process_status_line_theme()
end

-- stylua: ignore
local function status_line_theme_mywombat() ---@diagnostic disable-line
  vim.api.nvim_set_hl(0, 'MyStlNormal',       { fg = '#282828', bg = '#8ac6f2', ctermfg = 235, ctermbg = 117 })
  vim.api.nvim_set_hl(0, 'MyStlNormalNC',     { fg = '#303030', bg = '#6a6a6a', ctermfg = 236, ctermbg = 242 })
  vim.api.nvim_set_hl(0, 'MyStlNormalMode',   { fg = '#282828', bg = '#eeee00', ctermfg = 235, ctermbg = 226, bold = true })
  vim.api.nvim_set_hl(0, 'MyStlInsertMode',   { fg = '#282828', bg = '#95e454', ctermfg = 235, ctermbg = 119, bold = true })
  vim.api.nvim_set_hl(0, 'MyStlVisualMode',   { fg = '#282828', bg = '#f2c68a', ctermfg = 235, ctermbg = 216, bold = true })
  vim.api.nvim_set_hl(0, 'MyStlReplaceMode',  { fg = '#282828', bg = '#e5786d', ctermfg = 235, ctermbg = 203, bold = true })
  vim.api.nvim_set_hl(0, 'MyStlCommandMode',  { link = 'MyStlNormalMode', default = true })
  post_process_status_line_theme()
end

-- stylua: ignore
local function status_line_theme_catppuccin() ---@diagnostic disable-line
  vim.api.nvim_set_hl(0, 'MyStlNormalNC',     { fg = '#303030', bg = '#6a6a6a' })
  vim.api.nvim_set_hl(0, 'MyStlNormal',       { fg = '#181818', bg = '#82aaff' }) -- tokyonight
  vim.api.nvim_set_hl(0, 'MyStlNormalMode',   { fg = '#181818', bg = '#dddd00', bold = true })
  vim.api.nvim_set_hl(0, 'MyStlCommandMode',  { fg = '#181818', bg = '#fab388', bold = true })
  vim.api.nvim_set_hl(0, 'MyStlInsertMode',   { fg = '#181818', bg = '#a6e3a2', bold = true })
  vim.api.nvim_set_hl(0, 'MyStlVisualMode',   { fg = '#181818', bg = '#c099ff', bold = true }) -- tokyonight
  vim.api.nvim_set_hl(0, 'MyStlReplaceMode',  { fg = '#181818', bg = '#f38ba9', bold = true })
  post_process_status_line_theme()
end

-- stylua: ignore
local stl_hl_map = {
  C       = 'MyStlCommandMode',
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
  local gap = tail_glyph == '' and ' ' or ' '
  if active then
    local mode_group = stl_hl_map[m:upper():sub(1, 1)] or 'MyStlNormalMode'
    local head_string = string.format('%%#%s#%s', 'Normal_' .. mode_group, head_glyph)
    local mode_string = string.format('%%#%s#%s%s ', mode_group, gap, mode)
    local file_string = string.format('%%#%s# %%f%s │ %%l/%%L:%%v%s', 'MyStlNormal', mod, gap)
    local tail_string = string.format('%%#%s#%s%%#StatusLine#', 'MyStlNormal_Normal', tail_glyph)
    return head_string .. mode_string .. file_string .. tail_string
  else
    local head_string = string.format('%%#%s#%s', 'Normal_MyStlNormalNC', head_glyph)
    local file_string =
      string.format('%%#%s#%s%%f%s │ %%l/%%L:%%v%s', 'MyStlNormalNC', gap, mod, gap)
    local tail_string = string.format('%%#%s#%s%%#StatusLine#', 'MyStlNormalNC_Normal', tail_glyph)
    return head_string .. file_string .. tail_string
  end
end

local function mystl_setup()
  -- 修改 StatusLine 和 StatusLineNC 高亮组, 以适配 mystl 状态栏
  --hi Normal guibg=NONE ctermbg=NONE " 把 Normal 高亮组的背景色去掉, 可避免一些配色问题
  local normalHl = vim.api.nvim_get_hl(0, { name = 'Normal', link = false })
  local winSepHl = vim.api.nvim_get_hl(0, { name = 'WinSeparator', link = false })
  local fg = winSepHl[winSepHl.reverse and 'bg' or 'fg'] or 'NONE'
  local bg = normalHl[normalHl.reverse and 'fg' or 'bg'] or 'NONE'
  local ctermfg = winSepHl[winSepHl.reverse and 'ctermbg' or 'ctermfg'] or 'NONE'
  local ctermbg = normalHl[normalHl.reverse and 'ctermfg' or 'ctermbg'] or 'NONE'
  vim.api.nvim_set_hl(0, 'StatusLine', {
    fg = fg,
    bg = bg,
    ctermfg = ctermfg,
    ctermbg = ctermbg,
  })
  vim.api.nvim_set_hl(0, 'StatusLineNC', { link = 'StatusLine' })
  if not vim.regex([[^%!\|^%{%]]):match_str(vim.o.statusline) then
    vim.o.statusline = '─'
  end
  -- NOTE: 这里用 vim.opt 的话会导致奇怪的问题,
  --       例如 此时 local 和 global 不一致的时候, 会直接覆盖而不是添加
  vim.opt_global.fillchars:append({ stl = '─', stlnc = '─' })
end

-- init MyStatusLine
local mystl_theme = status_line_theme_catppuccin

local function mystl_callbak()
  mystl_setup()
  mystl_theme()
end

mystl_callbak()

vim.api.nvim_create_autocmd('ColorScheme', { callback = mystl_callbak })
vim.opt.showmode = false
vim.opt.statusline = '%{%v:lua.MyStatusLine()%}'
vim.opt.ruler = true -- 恢复 ruler 选项
-- :pwd<CR> 的时候会不及时刷新, 所以需要添加这个自动命令
vim.api.nvim_create_autocmd('ModeChanged', { callback = function() vim.cmd.redrawstatus() end })
-- 修正 quickfix 窗口的状态栏
vim.api.nvim_create_autocmd('BufReadPost', {
  callback = function()
    local stl = vim.opt_local.statusline:get() ---@diagnostic disable-line: undefined-field
    if stl ~= '' and stl ~= '─' then
      vim.opt_local.statusline = ''
    end
  end,
})

local filetypes = { 'Avante', 'AvanteInput', 'AvanteSelectedFiles' }
local filetypes_mapping = {}
for _, ft in ipairs(filetypes) do
  filetypes_mapping[ft] = true
end

local augroup = vim.api.nvim_create_augroup('mystl', {})
vim.api.nvim_create_autocmd('OptionSet', {
  pattern = { 'statusline', 'fillchars' },
  group = augroup,
  callback = function(event)
    local ft = vim.bo.filetype
    if not filetypes_mapping[ft] then
      return
    end
    local opt = event.match
    if opt == 'statusline' then
      vim.opt_local.statusline = '─'
    elseif opt == 'fillchars' then
      vim.opt_local.fillchars:append({ stl = '─', stlnc = '─' })
    end
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = filetypes,
  callback = function()
    vim.opt_local.statusline = '─'
    vim.opt_local.fillchars:append({ stl = '─', stlnc = '─' })
  end,
})

return M
