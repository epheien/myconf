-- 读取 vimrc
--local vimrc = vim.fn.stdpath("config") .. "/vimrc"
--vim.cmd.source(vimrc)

-- 插件设置入口, 避免在新环境中出现各种报错
-- NOTE: vim-plug 和 lazy.nvim 不兼容, 而 packer.nvim 已经停止维护
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

lazysetup('incline', {
  debounce_threshold = {
    falling = 50,
    rising = 10
  },
  hide = {
    cursorline = false,
    focused_win = false,
    only_win = false
  },
  highlight = {
    groups = {
      InclineNormal = {
        guifg = '#282828',
        guibg = '#8ac6f2',
        ctermfg = '235',
        ctermbg = '117',
      },
      InclineNormalNC = {
        guifg = '#969696',
        guibg = '#444444',
        ctermfg = '247',
        ctermbg = '238',
      }
    }
  },
  ignore = {
    buftypes = {},
    filetypes = {},
    floating_wins = true,
    unlisted_buffers = false,
    wintypes = {}
  },
  render = "basic",
  window = {
    margin = {
      horizontal = 0,
      vertical = 0
    },
    options = {
      signcolumn = "no",
      wrap = false
    },
    overlap = {
      borders = true,
      statusline = true,
      tabline = false,
      winbar = false
    },
    padding = 1,
    padding_char = " ",
    placement = {
      horizontal = "left",
      vertical = "bottom"
    },
    width = "fit",
    winhighlight = {
      active = {
        EndOfBuffer = "None",
        Normal = "InclineNormal",
        Search = "None"
      },
      inactive = {
        EndOfBuffer = "None",
        Normal = "InclineNormalNC",
        Search = "None"
      }
    },
    zindex = 50
  },
  render = function(props)
    local filename = vim.api.nvim_eval_statusline('%f', {winid = props.win})['str']
    local mod = vim.api.nvim_eval_statusline('%m%r', {winid = props.win})['str']
    if mod ~= '' then
      mod = ' ' .. mod
    end
    return {
      filename,
      mod,
    }
  end,
})

function CscopeFind(op, symbol)
  local cscope = require('cscope')
  local ok, res = cscope.cscope_get_result(1, op, symbol, false)
  if not ok then
    return {}
  end
  return res or {}
end
