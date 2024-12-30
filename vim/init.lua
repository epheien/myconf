require('config.options')
require('config.keymaps')
require('config.autocmds')
require('config.commands')

-- 使用 packadd 加载 pckr.nvim
--  $ mkdir -pv ~/.config/nvim/pack/pckr/opt/
--  $ git clone --filter=blob:none https://github.com/epheien/pckr.nvim.git ~/.config/nvim/pack/pckr/opt/pckr.nvim
vim.opt.packpath:append(vim.fn.stdpath('config'))
assert(
  pcall(vim.cmd.packadd, 'pckr.nvim'),
  'Failed to init pckr.nvim, '
    .. 'try to run `git clone --filter=blob:none https://github.com/epheien/pckr.nvim.git ~/.config/nvim/pack/pckr/opt/pckr.nvim`'
)

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
    require('utils').setup_colorscheme('gruvbox')
  end
end

require('config.pckr')
require('config.float-help')
require('config.mystl')
require('config.alacritty-mouse-fix')
