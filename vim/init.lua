require('config.options')
require('config.keymaps')
require('config.autocmds')
require('config.commands')

-- pckr or lazy
vim.g.package_manager = 'lazy'

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
assert(
  (vim.uv or vim.loop).fs_stat(path),
  'Failed to init pckr.nvim, '
    .. 'try to run `git clone --filter=blob:none https://github.com/epheien/pckr.nvim.git ~/.config/nvim/pack/pckr/opt/pckr.nvim`'
)
vim.opt.rtp:prepend(path)

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
    vim.api.nvim_exec_autocmds('ColorScheme', { group = 'vimrc' })
  end
end

if vim.g.package_manager == 'pckr' then
  require('utils').add_plugins(require('plugins'))
else
  require('lazy').setup({
    spec = { import = 'plugins' },
    root = vim.fn.stdpath('config') .. '/pack/pckr/opt',
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
        },
      },
    },
  })
end

require('config.float-help')
require('config.mystl')
require('config.alacritty-mouse-fix')
