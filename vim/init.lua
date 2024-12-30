require('config.options')
require('config.keymaps')
require('config.autocmds')
require('config.commands')

-- 使用 packadd 加载 pckr.nvim
--  $ mkdir -pv ~/.config/nvim/pack/pckr/opt/
--  $ git clone --filter=blob:none https://github.com/epheien/pckr.nvim.git ~/.config/nvim/pack/pckr/opt/pckr.nvim
vim.opt.packpath:append(vim.fn.stdpath('config'))
assert(pcall(vim.cmd.packadd, 'pckr.nvim'), 'Failed to init pckr.nvim, ' ..
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
    require('utils').setup_colorscheme('gruvbox')
  end
end
setup_colorscheme()

require('config.pckr')
require('config.float-help')
require('config.mystl')
require('config.alacritty-mouse-fix')

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
