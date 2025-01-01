-- pckr or lazy
vim.g.package_manager = 'lazy'

require('config.options')

local function load_config()
  require('config.autocmds')
  require('config.keymaps')
  require('config.commands')
end

if vim.g.package_manager == 'lazy' then
  vim.api.nvim_create_autocmd('User', {
    pattern = 'VeryLazy',
    once = true,
    callback = load_config,
  })
else
  load_config()
end

-- 使用 packadd 加载 pckr.nvim
--  $ mkdir -pv ~/.config/nvim/pack/pckr/opt/
--  $ git clone --filter=blob:none https://github.com/epheien/pckr.nvim.git ~/.config/nvim/pack/pckr/opt/pckr.nvim
vim.opt.packpath:append(vim.fn.stdpath('config'))
---@diagnostic disable-next-line
local path = vim.fs.joinpath(
  vim.fn.stdpath('config'), ---@diagnostic disable-line
  'pack',
  'pckr',
  'opt',
  string.format('%s.nvim', vim.g.package_manager)
)
local msg = ''
if vim.g.package_manager == 'lazy' then
  msg = string.format(
    'Failed to init lazy.nvim, '
      .. 'try to run `git clone --filter=blob:none --branch=stable '
      .. 'https://github.com/folke/lazy.nvim.git %s`',
    path
  )
else
  msg = string.format(
    'Failed to init pckr.nvim, '
      .. 'try to run `git clone --filter=blob:none '
      .. 'https://github.com/epheien/pckr.nvim.git %s`',
    path
  )
end
assert((vim.uv or vim.loop).fs_stat(path), msg) ---@diagnostic disable-line
vim.opt.rtp:prepend(path)

vim.cmd([[
function g:SetupColorschemePost(...)
  if g:colors_name ==# 'gruvbox'
    " 这个配色默认情况下，字符串和函数共用一个配色，要换掉！
    hi! link String Constant
    " 终端下的光标颜色貌似不受主题的控制，受制于终端自身的设置
    hi Cursor guifg=black guibg=yellow gui=NONE ctermfg=16 ctermbg=226 cterm=NONE
    hi Todo guifg=orangered guibg=yellow2 gui=NONE ctermfg=202 ctermbg=226 cterm=NONE
    "hi IncSearch guifg=#181826 guibg=#7ec9d9 gui=NONE cterm=NONE
    hi Search guifg=gray80 guibg=#445599 gui=NONE ctermfg=252 ctermbg=61 cterm=NONE
    hi Directory guifg=#8094b4 gui=bold ctermfg=12 cterm=bold
    " tagbar 配色
    hi! link TagbarAccessPublic GruvboxAqua
    hi! link TagbarAccessProtected GruvboxPurple
    hi! link TagbarAccessPrivate GruvboxRed
    hi! link TagbarSignature Normal
    hi! link TagbarKind Constant
    hi! link CurSearch Search
    hi! link FloatBorder WinSeparator
    hi! link SpecialKey Special
    hi! SignColumn guibg=NONE ctermbg=NONE
    " GitGutter
    hi! link GitGutterAdd GruvboxGreen
    hi! link GitGutterChange GruvboxAqua
    hi! link GitGutterDelete GruvboxRed
    hi! link GitGutterChangeDelete GruvboxYellow
    " Signature
    hi! link SignatureMarkText   GruvboxBlue
    hi! link SignatureMarkerText GruvboxPurple
  endif
  " 配合 incline
  "hi Normal guibg=NONE ctermbg=NONE " 把 Normal 高亮组的背景色去掉, 可避免一些配色问题
  let normalHl = nvim_get_hl(0, {'name': 'Normal', 'link': v:false})
  let winSepHl = nvim_get_hl(0, {'name': 'WinSeparator', 'link': v:false})
  let fg = printf('#%06x', get(winSepHl, get(winSepHl, 'reverse') ? 'bg' : 'fg'))
  let bg = printf('#%06x', get(normalHl, get(normalHl, 'reverse') ? 'fg' : 'bg'))
  let ctermfg = get(winSepHl, get(winSepHl, 'reverse') ? 'ctermbg' : 'ctermfg')
  let ctermbg = get(normalHl, get(normalHl, 'reverse') ? 'ctermfg' : 'ctermbg')
  call nvim_set_hl(0, 'StatusLine', {'fg': fg, 'bg': bg, 'ctermfg': ctermfg, 'ctermbg': ctermbg})
  hi! link StatusLineNC StatusLine
  if &statusline !~# '^%!\|^%{%'
    set statusline=─
  endif
  set fillchars+=stl:─,stlnc:─
endfunction
]])

vim.api.nvim_create_autocmd('ColorScheme', {
  group = vimrc_group,
  callback = function(args)
    vim.call('g:SetupColorschemePost', args.file, args.match)
  end,
})

-- 直接用内置的 packadd 初始化主题
if pcall(vim.cmd.packadd, 'gruvbox.nvim') then
  require('gruvbox').setup({
    bold = true,
    italic = {
      strings = false,
      emphasis = false,
      comments = false,
      operators = false,
      folds = false,
    },
    terminal_colors = vim.fn.has('gui_running') == 1,
  })
  if vim.env.TERM_PROGRAM ~= 'Apple_Terminal' then
    vim.o.background = 'dark'
    require('gruvbox').load()
    vim.api.nvim_exec_autocmds('ColorScheme', { modeline = false })
  end
end

if vim.g.package_manager == 'pckr' then
  require('utils').add_plugins(require('plugins'))
else
  require('lazy').setup({
    spec = { import = 'plugins' },
    root = vim.fn.stdpath('config') .. '/pack/pckr/opt',
    rocks = {
      enabled = false,
    },
    install = {
      missing = false,
    },
    checker = { enable = false },
    change_detection = { enabled = false },
    performance = {
      rtp = {
        -- disable some rtp plugins
        disabled_plugins = {
          --'gzip',
          -- "matchit",
          -- "matchparen",
          -- "netrwPlugin",
          'tarPlugin',
          'tohtml',
          'tutor',
          'zipPlugin',
          'spellfile',
        },
      },
    },
  })
end

require('config.float-help')
require('config.mystl')
require('config.alacritty-mouse-fix')