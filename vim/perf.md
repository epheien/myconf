# 性能优化

## 启动速度优化

### LazyVim 独有加载
```txt
/Users/eph/.config/lazyvim/init.lua
/Users/eph/.config/lazyvim/lazy/snacks.nvim/plugin/snacks.lua
autocommands
autocommands
loop
require('catppuccin')
require('catppuccin')
require('catppuccin.lib.hashing')
require('config.lazy')
require('lazyvim')
require('lazyvim.config')
require('lazyvim.config.options')
require('lazyvim.util')
require('lazyvim.util.deprecated')
require('lazyvim.util.inject')
require('lazyvim.util.pick')
require('lazyvim.util.plugin')
require('lazyvim.util.ui')
require('nvim-treesitter.query_predicates')
require('snacks')
require('snacks.dashboard')
require('snacks.input')
require('snacks.scope')
require('snacks.util')
require('vim.func')
require('vim.func._memoize')
require('vim.treesitter.language')
require('vim.treesitter.query')
require('vim.ui')
update
```

### 自用 nvim 独有加载
```txt
/Users/eph/.config/nvim/init.lua
/Users/eph/.local/share/nvim/rplugin.vim
require('config.alacritty-mouse-fix')
require('config.autocmds')
require('config.commands')
require('config.float-help')
require('config.keymaps')
require('config.mystl')
require('gruvbox')
require('plugins.aerial')
require('plugins.core')
require('plugins.cscope_maps')
require('plugins.local')
require('plugins.lualine')
require('plugins.neo-tree')
require('plugins.noice')
require('plugins.nvim-tree')
require('plugins.telescope')
require('plugins.vim-plugins')
require('plugins.window-picker')
require('utils')
require('vim.F')
require('vim.diagnostic')
require('vim.highlight')
require('vim.lsp')
require('vim.lsp._changetracking')
require('vim.lsp._snippet_grammar')
require('vim.lsp.log')
require('vim.lsp.protocol')
require('vim.lsp.rpc')
require('vim.lsp.sync')
require('vim.lsp.util')
```
