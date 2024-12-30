local utils = require('utils')

-- 使用 packadd 加载 pckr.nvim
--  $ mkdir -pv ~/.config/nvim/pack/pckr/opt/
--  $ git clone --filter=blob:none https://github.com/epheien/pckr.nvim.git ~/.config/nvim/pack/pckr/opt/pckr.nvim
vim.opt.packpath:append(vim.fn.stdpath('config'))
assert(pcall(vim.cmd.packadd, 'pckr.nvim'), 'Failed to init pckr.nvim, '
  ..
  'try to run `git clone --filter=blob:none https://github.com/epheien/pckr.nvim.git ~/.config/nvim/pack/pckr/opt/pckr.nvim`')

-- 直接用内置的 packadd 初始化主题
local function setup_colorscheme()
  if not pcall(vim.cmd.packadd, 'gruvbox.nvim') then
    return
  end
  require('gruvbox').setup({
    bold = true,
    italic = {
      strings = false,
      emphasis = false,
      comments = false,
      operators = false,
      folds = false
    },
    terminal_colors = vim.fn.has('gui_running') == 1
  })
  if vim.env.TERM_PROGRAM ~= 'Apple_Terminal' then
    utils.setup_colorscheme('gruvbox')
  end
end
setup_colorscheme()

-- 插件设置入口, 避免在新环境中出现各种报错
-- NOTE: vim-plug 和 lazy.nvim 不兼容, 而 packer.nvim 已经停止维护
local function lazysetup(plugin, config) -- {{{
  local ok, mod = pcall(require, plugin)
  if not ok then
    --print('ignore lua plugin:', plugin)
    return
  end
  if type(config) == 'function' then
    config(mod)
  else
    mod.setup(config)
  end
end
-- }}}

local function setup_cscope_maps() --{{{
  lazysetup('cscope_maps', {
    disable_maps = true,
    skip_input_prompt = false,
    prefix = '',
    cscope = {
      db_file = './GTAGS',
      exec = 'gtags-cscope',
      skip_picker_for_single_result = true
    }
  })
end
--}}}

require('config.pckr')

-- floating window for :help {{{
local help_winid = -1
local create_help_floatwin = function()
  if not vim.api.nvim_win_is_valid(help_winid) then
    local bufid = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = bufid }) -- 会被 :h 覆盖掉
    vim.api.nvim_set_option_value("buftype", "help", { buf = bufid })
    local width = math.min(vim.o.columns, 100)
    local col = math.floor((vim.o.columns - width) / 2)
    help_winid = vim.api.nvim_open_win(bufid, false, {
      relative = 'editor',
      row = 1,
      col = col,
      width = width,
      height = math.floor(vim.o.lines / 2),
      border = 'rounded',
    })
  end
  vim.api.nvim_set_current_win(help_winid)
  -- NOTE: floating window 的 winhighlight 选项会继承自调用此函数的窗口
  --       但是用下面的方法设置选项就没有问题
  local opt = vim.opt_local.winhighlight
  if not opt:get().NormalFloat then
    opt:append({ NormalFloat = 'Normal' })
  end
end
vim.keymap.set('c', '<CR>', function()
  if vim.fn.getcmdtype() ~= ':' then
    return '<CR>'
  end
  local line = vim.fn.getcmdline()
  if string.sub(line, 1, 1) == ' ' then -- 如果命令有前导的空格, 那么就 bypass
    return '<CR>'
  end
  local ok, parsed = pcall(vim.api.nvim_parse_cmd, line, {})
  if not ok then
    return '<CR>'
  end
  if parsed.cmd == 'help' then
    vim.schedule(function()
      create_help_floatwin()
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, true, true), 'cn', false)
    end)
    return ''
  elseif parsed.cmd == 'make' then -- 替换 make 命令为 AsyncRun make
    --vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Home>AsyncRun <End><CR>', true, true, true), 'cn', false)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-c>', true, true, true), 'cn', false)
    vim.schedule(function()
      vim.cmd('AsyncRun ' .. line) -- NOTE: 设置 g:asyncrun_open > 0 以自动打开 qf
      --vim.cmd.echo(vim.fn.string(':' .. line))
    end)
    return ''
  elseif parsed.cmd == 'terminal' then -- terminal 命令替换为 Terminal
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-c>', true, true, true), 'cn', false)
    vim.schedule(function()
      vim.cmd('T' .. string.sub(line, 2)) -- NOTE: 设置 g:asyncrun_open > 0 以自动打开 qf
    end)
    return ''
  end
  return '<CR>'
end, {silent = true, expr = true})
vim.keymap.set('n', '<F1>', function()
  create_help_floatwin()
  vim.cmd('help')
end)
vim.keymap.set('i', "<F1>", "<Nop>")
-- }}}

-- 手动修正 Alacritty 终端模拟器鼠标点击时, 光标仍然闪烁的问题 {{{
local inited_on_key = false
local stop_on_key = false
local cursor_blinkon_opt = { "n-v-c:block", "i-ci-ve:ver25", "r-cr:hor20", "o:hor50",
  "a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor", "sm:block-blinkwait175-blinkoff150-blinkon175" }
local cursor_blinkoff_opt = { "n-v-c:block", "i-ci-ve:ver25", "r-cr:hor20", "o:hor50",
  "a:Cursor/lCursor", "sm:block-blinkwait175-blinkoff150-blinkon175" }
local setup_on_key = function()
  if inited_on_key then
    stop_on_key = false
    return
  end
  inited_on_key = true
  local prs = vim.keycode("<LeftMouse>")
  local rel = vim.keycode("<LeftRelease>")
  vim.on_key(function(k)
    if stop_on_key then
      return
    end
    if k == prs then
      vim.opt.guicursor = cursor_blinkoff_opt
    elseif k == rel then
      vim.opt.guicursor = cursor_blinkon_opt
    end
  end)
end
vim.api.nvim_create_user_command('FixMouseClick', function() setup_on_key() end, { nargs = 0 })
vim.api.nvim_create_user_command('StopFixMouseClick', function()
  stop_on_key = true
  vim.opt.guicursor = cursor_blinkon_opt
end, { nargs = 0 })
-- 暂时所知仅 Alacritty 需要修正
local TERM_PROGRAM = os.getenv('TERM_PROGRAM')
if not (TERM_PROGRAM == 'kitty' or TERM_PROGRAM == 'iTerm' or
      TERM_PROGRAM == 'Apple_Terminal' or vim.fn.has('gui_running') == 1) then
  setup_on_key()
end
-- }}}

-- MyStatusLine, 简易实现以提高载入速度 {{{
local function create_transitional_hl(left, right)
  local name = left
  local opts = vim.api.nvim_get_hl(0, { name = name, link = false })
  if not vim.tbl_isempty(vim.api.nvim_get_hl(0, { name = name .. 'Reverse' })) then
    return false -- 已存在的话就忽略
  end
  if vim.tbl_isempty(opts) then
    return false
  end
  local right_opts = vim.api.nvim_get_hl(0, { name = right, link = false })
  opts = vim.tbl_deep_extend('force', opts, { reverse = opts.reverse and false or true, fg = right_opts.bg or 'NONE' })
  vim.api.nvim_set_hl(0, name .. 'Reverse', opts) ---@diagnostic disable-line
  return true
end

local function status_line_theme_gruvbox() ---@diagnostic disable-line
  vim.api.nvim_set_hl(0, 'MyStlNormal', { fg = '#a89984', bg = '#504945' }) -- 246 239
  vim.api.nvim_set_hl(0, 'MyStlNormalNC', { fg = '#7c6f64', bg = '#3c3836' }) -- 243 237
  vim.api.nvim_set_hl(0, 'MyStlNormalMode', { fg = '#282828', bg = '#a89984' }) -- 235 246
  vim.api.nvim_set_hl(0, 'MyStlInsertMode', { fg = '#282828', bg = '#83a598' }) -- 235 109
  vim.api.nvim_set_hl(0, 'MyStlVisualMode', { fg = '#282828', bg = '#fe8019' }) -- 235 208
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
  vim.api.nvim_set_hl(0, 'MyStlReplaceMode', { fg = '#282828', bg = '#e5786d', ctermfg = 235, ctermbg = 203, bold = true })
  create_transitional_hl('MyStlNormal', 'Normal')
  create_transitional_hl('MyStlNormalNC', 'Normal')

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
local mode_table = require('config/mystl').mode_table
local trail_glyph = require('utils').only_ascii() and '' or ''
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
    return ('%#' .. mode_group .. '# ' .. mode ..
      ' %#MyStlNormal# %f' .. mod .. ' │ %l/%L,%v %#MyStlNormalReverse#'
      .. trail_glyph .. '%#StatusLine#')
  else
    return '%#MyStlNormalNC# %f' .. mod .. ' │ %l/%L,%v %#MyStlNormalNCReverse#' .. trail_glyph .. '%#StatusLineNC#'
  end
end

-- init MyStatusLine
local mystl_theme = status_line_theme_mywombat
mystl_theme()
vim.api.nvim_create_autocmd('ColorScheme', {callback = mystl_theme})
vim.opt.laststatus = 2
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

-- 增强 <C-g> 显示的信息 {{{
vim.keymap.set('n', '<C-g>', function()
  local msg_list = {}
  local fname = vim.fn.expand('%:p')
  table.insert(msg_list, fname ~= '' and fname or vim.api.nvim_eval_statusline('%f', {}).str)
  if vim.api.nvim_eval_statusline('%w', {}).str ~= '' then
    table.insert(msg_list, vim.api.nvim_eval_statusline('%w', {}).str)
  end
  if vim.o.readonly then
    table.insert(msg_list, '[RO]')
  end
  if vim.o.filetype ~= '' then
    table.insert(msg_list, string.format('[%s]', vim.o.filetype))
  end
  if vim.o.fileformat ~= '' then
    table.insert(msg_list, string.format('[%s]', vim.o.fileformat))
  end
  if vim.o.fileencoding ~= '' then
    table.insert(msg_list, string.format('[%s]', vim.o.fileencoding))
  end
  if fname ~= '' and vim.fn.filereadable(fname) == 1 then
    table.insert(msg_list, vim.fn.strftime("%Y-%m-%d %H:%M:%S", vim.fn.getftime(fname)))
  end
  vim.cmd.echo(vim.fn.string(vim.fn.join(msg_list, ' ')))

  if vim.g.outline_loaded == 1 then
    local outline = require('outline') ---@diagnostic disable-line: different-requires
    if outline.is_open() then
      outline.follow_cursor({ focus_outline = false })
    end
  end
end)
-- }}}

-- • Enabled treesitter highlighting for:
--   • Treesitter query files
--   • Vim help files
--   • Lua files
-- 额外的默认使用 treesitter 的文件类型
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'c', 'vim', 'markdown' },
  callback = function()
    if vim.bo.filetype == 'markdown' then
      -- 非 floating window 用 treesiter 高亮, 否则就用 syntax 高亮
      if vim.api.nvim_win_get_config(0).relative == '' then
        vim.treesitter.start()
      end
    else
      vim.treesitter.start()
    end
  end
})

vim.api.nvim_create_autocmd('BufWinEnter', {
  pattern = '*',
  callback = function()
    if vim.bo.filetype == 'help' and vim.api.nvim_win_get_config(0).relative ~= '' then
      local opt = vim.opt_local.winhighlight
      if not opt:get().NormalFloat then
        opt:append({ NormalFloat = 'Normal' })
      end
    end
  end
})

local open_floating_preview = vim.lsp.util.open_floating_preview
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.util.open_floating_preview = function(contents, syntax, opts)
  local bak = vim.g.syntax_on
  vim.g.syntax_on = nil
  local floating_bufnr, floating_winnr = open_floating_preview(contents, syntax, opts)
  vim.g.syntax_on = bak
  if syntax == 'markdown' then vim.wo[floating_winnr].conceallevel = 2 end
  return floating_bufnr, floating_winnr
end

local nvim_open_win = vim.api.nvim_open_win
---@diagnostic disable-next-line: duplicate-set-field
vim.api.nvim_open_win = function(buffer, enter, config)
  if config.relative ~= '' then
    if config.title == 'Outline Status' or config.title == 'Outline Help' then
      config.border = 'none'
    end
  end
  return nvim_open_win(buffer, enter, config)
end

vim.api.nvim_create_user_command('Capture', function(opt)
  require('utils').floatwin_run(opt.args)
end, {
  nargs = '+',
  complete = function(arg_lead, cmd_line, cursor_pos) ---@diagnostic disable-line
    local line = vim.fn.substitute(cmd_line, [=[^\s*\w\+\s\+]=], '', '')
    return vim.fn.getcompletion(line, 'cmdline')
  end
})

------------------------------------------------------------------------------
-- vim:set fdm=marker fen fdl=0:
