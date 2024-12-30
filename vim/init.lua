require('config/options')
require('config/keymaps')
require('config/autocmds')
require('config/commands')

if vim.fn.has('nvim-0.8.0') == 1 then
  require('init-nvim')
end
