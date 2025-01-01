# 性能优化

## 启动速度优化

对比 LazyVim 和自用的启动加载
```sh
rm -fv nvim.txt && nvim -c q --startuptime nvim.txt && tail nvim.txt
rm -fv nvimlazy.txt && nvimlazy -c q --startuptime nvimlazy.txt && tail nvimlazy.txt
awk '{print $NF}' nvimlazy.txt | sort > a.txt
awk '{print $NF}' nvim.txt | sort > b.txt
comm -23 a.txt b.txt # 打印 a.txt 独有的行
comm -13 a.txt b.txt # 打印 b.txt 独有的行
```

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
/Users/eph/.config/nvim/pack/pckr/opt/snacks.nvim/plugin/snacks.lua
/Users/eph/opt/nvim-macos-arm64/share/nvim/runtime/plugin/gzip.vim
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
require('plugins.snacks')
require('plugins.telescope')
require('plugins.vim-plugins')
require('plugins.window-picker')
require('utils')
```
