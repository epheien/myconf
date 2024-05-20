-- 读取 vimrc
--local vimrc = vim.fn.stdpath("config") .. "/vimrc"
--vim.cmd.source(vimrc)

-- 插件设置入口, 避免在新环境中出现各种报错
function lazysetup(plugin, config)
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

-- NOTE: Plug 管理的插件需要放到 lazy 初始化之前
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

lazysetup('nvim-tree', function()
  require('config/nvim-tree')
end)

lazysetup('indent_blankline', {})

lazysetup('lazy', {
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.7',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },
  {
    'stevearc/oil.nvim',
    opts = {},
    lazy = true,
    -- Optional dependencies
    --dependencies = { "nvim-tree/nvim-web-devicons" },
  }
})

lazysetup('telescope', function(mod) mod.setup({
  defaults = {
    -- Default configuration for telescope goes here:
    -- config_key = value,
    mappings = {
      i = {
        --["<Esc>"] = require('telescope.actions').close,
        ["<C-j>"] = require('telescope.actions').move_selection_next,
        ["<C-k>"] = require('telescope.actions').move_selection_previous,
      }
    }
  },
}) end)

lazysetup('noice', {
  cmdline = {
    format = {
      help = false,
      lua = false,
      filter = false,
      --search_down = { icon = "/ ⌄" },
      --search_up = { icon = "? ⌃" },
    },
  },
  messages = {
    --enabled = false, -- false 会使用 cmdline, 避免闪烁
    view = 'mini',
    view_error = 'mini',
    view_warn = 'mini',
    view_history = 'popup',
  },
  commands = {
    history = {
      view = 'popup',
    },
  },
  format = {
    level = {
      icons = {
        error = "✖",
        warn = "▼",
        info = "●",
      },
    },
  },
})

function CscopeFind(op, symbol)
  local cscope = require('cscope')
  local ok, res = cscope.cscope_get_result(1, op, symbol, false)
  if not ok then
    return {}
  end
  return res or {}
end
