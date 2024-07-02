-- 读取 vimrc
--local vimrc = vim.fn.stdpath("config") .. "/vimrc"
--vim.cmd.source(vimrc)

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

local function setup_telescope() -- {{{
  local opts = {
    -- Default configuration for telescope goes here:
    -- config_key = value,
    mappings = {
      i = {
        ["<Esc>"] = require('telescope.actions').close,
        ["<C-j>"] = require('telescope.actions').move_selection_next,
        ["<C-k>"] = require('telescope.actions').move_selection_previous,
        ["<C-l>"] = false,
        ["<C-u>"] = false,
        ["<C-b>"] = require('telescope.actions').preview_scrolling_up,
        ["<C-f>"] = require('telescope.actions').preview_scrolling_down,
      }
    },
    sorting_strategy = "ascending",
    layout_config = {
      prompt_position = 'top',
    },
  }
  lazysetup('telescope', function(mod)
    mod.setup({
      --defaults = require('telescope.themes').get_dropdown(opts),
      defaults = opts,
      pickers = {
        tags = {
          only_sort_tags = true,
        },
        current_buffer_tags = {
          only_sort_tags = true,
        },
        find_files = {
          no_ignore = true,
          no_ignore_parent = true,
        },
      },
    })
  end)
  vim.api.nvim_set_hl(0, 'TelescopeBorder', {link = 'WinSeparator', force = true})
  vim.api.nvim_set_hl(0, 'TelescopeTitle', {link = 'Title', force = true})
  -- telescope 的 undo 插件
  require("telescope").load_extension("undo")
end
--}}}

local function setup_noice() -- {{{
  lazysetup('noice', {
    views = {
      align = 'message-left',
      position = {
        col = 0,
      }
    },
    cmdline_popup = {
      position = {
        row = 5,
        col = "00%",
      },
      size = {
        width = 60,
        height = "auto",
      },
    },
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
end
-- }}}

-- incline setup {{{
local InclineNormalNC = {
    guifg = '#282828',
    guibg = '#6a6a6a',
    --guifg = '#969696',
    --guibg = '#585858',
    ctermfg = '235',
    ctermbg = '242',
}
local InclineNormal = {
  guifg = '#282828',
  guibg = '#8ac6f2',
  ctermfg = '235',
  ctermbg = '117',
  --guifg = '#444444',
  --guibg = '#9999ff',
  --ctermfg = '238',
  --ctermbg = '105',
}
local mode_table = {
  ['n']      = 'NORMAL',
  ['no']     = 'O-PENDING',
  ['nov']    = 'O-PENDING',
  ['noV']    = 'O-PENDING',
  ['no\22'] = 'O-PENDING',
  ['niI']    = 'NORMAL',
  ['niR']    = 'NORMAL',
  ['niV']    = 'NORMAL',
  ['nt']     = 'NORMAL',
  ['ntT']    = 'NORMAL',
  ['v']      = 'VISUAL',
  ['vs']     = 'VISUAL',
  ['V']      = 'V-LINE',
  ['Vs']     = 'V-LINE',
  ['\22']   = 'V-BLOCK',
  ['\22s']  = 'V-BLOCK',
  ['s']      = 'SELECT',
  ['S']      = 'S-LINE',
  ['\19']   = 'S-BLOCK',
  ['i']      = 'INSERT',
  ['ic']     = 'INSERT',
  ['ix']     = 'INSERT',
  ['R']      = 'REPLACE',
  ['Rc']     = 'REPLACE',
  ['Rx']     = 'REPLACE',
  ['Rv']     = 'V-REPLACE',
  ['Rvc']    = 'V-REPLACE',
  ['Rvx']    = 'V-REPLACE',
  ['c']      = 'COMMAND',
  ['cv']     = 'EX',
  ['ce']     = 'EX',
  ['r']      = 'REPLACE',
  ['rm']     = 'MORE',
  ['r?']     = 'CONFIRM',
  ['!']      = 'SHELL',
  ['t']      = 'TERMINAL',
}
local function slim_mode(mode)
  local dash_pos = mode:find("-")
  if not dash_pos then return mode:sub(1, 1) end
  return mode:sub(1, 1) .. mode:sub(dash_pos + 1, dash_pos + 1)
end
local function make_mode_display(m)
  local group = 'InclineNormalMode'
  local mode = mode_table[m]
  if m == 'n' then
    -- 用默认值
  elseif mode == 'INSERT' then
    group = 'IncelineInsertMode'
  elseif mode == 'TERMINAL' then
    group = 'IncelineTerminalMode'
  elseif mode == 'VISUAL' or mode == 'V-LINE' or mode == 'V-BLOCK' then
    group = 'IncelineVisualMode'
  elseif mode == 'SELECT' or mode == 'S-LINE' or mode == 'S-BLOCK' then
    group = 'IncelineSelectMode'
  elseif mode == 'REPLACE' or mode == 'V-REPLACE' then
    group = 'IncelineReplaceMode'
  else
    -- 兜底用默认值
  end
  return {
    string.format(' %s ', slim_mode(mode)),
    group = group,
  }
end
local function setup_incline()
  -- 生成需要用到的高亮组
  --vim.cmd([[hi InclineNormalMode guifg=#282828 guibg=#E0E000 ctermfg=235 ctermbg=184]])
  vim.api.nvim_set_hl(0, 'InclineNormalMode', {fg='#282828', bg='#E0E000', ctermfg=235, ctermbg=184})
  vim.cmd([[hi! IncelineInsertMode ctermfg=235 ctermbg=119 guifg=#282828 guibg=#95e454]])
  vim.cmd([[hi! IncelineTerminalMode ctermfg=235 ctermbg=119 guifg=#282828 guibg=#95e454]])
  vim.cmd([[hi! IncelineVisualMode ctermfg=235 ctermbg=216 guifg=#282828 guibg=#f2c68a]])
  vim.cmd([[hi! IncelineSelectMode ctermfg=235 ctermbg=216 guifg=#282828 guibg=#f2c68a]])
  vim.cmd([[hi! IncelineReplaceMode ctermfg=235 ctermbg=203 guifg=#282828 guibg=#e5786d]])
  -- set noshowmode
  vim.o.showmode = false
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
        InclineNormal = InclineNormal,
        InclineNormalNC = InclineNormalNC,
      }
    },
    ignore = {
      buftypes = {},
      filetypes = {},
      floating_wins = true,
      unlisted_buffers = false,
      wintypes = {}
    },
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
      padding = 0,
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
      zindex = 1, -- 最小的 zindex, 以避免遮盖其他窗口
    },
    render = function(props)
      local filename = vim.api.nvim_eval_statusline('%f', {winid = props.win})['str']
      local mode = {}
      local mod = vim.api.nvim_eval_statusline('%m%r', {winid = props.win})['str']
      local active = (vim.api.nvim_tabpage_get_win(0) == props.win)
      local left_icon = ' '
      local trail_icon = ' '
      local mode_padding = ''
      -- 全局的背景色
      local guibg = '#282828'
      local ctermbg = 235
      --    
      local trail_glyph = ''
      if vim.fn.OnlyASCII() ~= 0 then trail_glyph = '' end
      if active then
        --left_icon = {'', guibg = guibg, guifg = InclineNormal.guibg, ctermbg = ctermbg, ctermfg = InclineNormal.ctermbg}
        trail_icon = {trail_glyph, guibg = guibg, guifg = InclineNormal.guibg, ctermbg = ctermbg, ctermfg = InclineNormal.ctermbg}
        mode = make_mode_display(vim.fn.mode())
        if #mode ~= 0 then mode_padding = ' '; left_icon = '' end
      else
        --left_icon = {'', guibg = guibg, guifg = InclineNormalNC.guibg, ctermbg = ctermbg, ctermfg = InclineNormalNC.ctermbg}
        trail_icon = {trail_glyph, guibg = guibg, guifg = InclineNormalNC.guibg, ctermbg = ctermbg, ctermfg = InclineNormalNC.ctermbg}
      end
      if mod ~= '' then
        mod = ' ' .. mod
      end
      local result = {
        left_icon,
        mode,
        mode_padding,
        filename,
        mod,
      }

      -- 简单地添加 ruler 信息
      local ruler = vim.api.nvim_eval_statusline(' %l/%L,%v ', {winid = props.win})['str']
      ruler = ' │' .. ruler
      table.insert(result, ruler)

      table.insert(result, trail_icon)
      return result
    end,
  })
end
-- }}}
setup_incline()

local function setup_lualine() -- {{{
  local lualine = require('lualine')
  local opts = {
    sections = {},
    tabline = {
    },
  }
  lualine.setup(opts)
end
-- }}}

-- ======================================================================
-- 以下开始是 pckr.nvim 管理的插件
-- ======================================================================
local function setup_pckr()
  local plugin = 'pckr'
  local ok, pckr = pcall(require, plugin)
  if not ok then
    print('ignore lua plugin:', plugin)
    return
  end

  local cmd = require('pckr.loader.cmd')
  local keys = require('pckr.loader.keys') -- function(mode, key, rhs?, opts?)
  local event = require('pckr.loader.event')

  pckr.setup({
    package_root = vim.fn.stdpath('config'),
    autoinstall = false,
  })

  local plugins = {
    -- telescope
    {
      'nvim-telescope/telescope.nvim',
      tag = '0.1.8',
      requires = {'nvim-lua/plenary.nvim', 'debugloop/telescope-undo.nvim'},
      cond = {cmd('Telescope')},
      config = function() require('config/telescope') end,
    };

    -- nvim-tree
    {
      --'nvim-tree/nvim-tree.lua',
      'epheien/nvim-tree.lua',
      requires = {'nvim-tree/nvim-web-devicons', 'nvim-telescope/telescope.nvim'},
      cond = {cmd('NvimTreeOpen'), cmd('NvimTreeToggle')},
      config = function() require('config/nvim-tree') end,
    };

    {'stevearc/aerial.nvim', cond = cmd('AerialOpen'), config = function() require('aerial').setup() end};
    {'nvim-treesitter/nvim-treesitter', cond = {cmd('TSBufToggle')}};
    {'lukas-reineke/indent-blankline.nvim', cond = cmd('IBLEnable'), config = function() require('ibl').setup() end};

    -- 可让你在 nvim buffer 中新增/删除/改名文件的文件管理器
    {'stevearc/oil.nvim', cond = cmd('Oil'), config = function() require('oil').setup() end};

    {
      'neoclide/coc.nvim',
      branch = 'release',
      cond = cmd('CocStart'),
      requires = {'Shougo/neosnippet.vim', 'Shougo/neosnippet-snippets'},
    };

    {'dhananjaylatkar/cscope_maps.nvim', cond = {cmd('Cs'), cmd('Cstag')}, config = setup_cscope_maps};
    {'epheien/vim-gutentags', cond = event({'BufReadPre'}), requires = {'dhananjaylatkar/cscope_maps.nvim'}};

  }

  -- 暂时只在 macOS 试验性地使用 nvim-cmp 和 nvim-lspconfig
  if vim.fn.has('mac') == 1 then
    -- 事件顺序: BufReadPre => FileType => BufReadPost
    local mac_plugins = {
      {
        "neovim/nvim-lspconfig",
        cond = event({'BufReadPre'}),
        config = function() require('config/nvim-lspconfig') end,
        requires = {'ray-x/lsp_signature.nvim'}, -- 需要在 lsp attach 之前加载
      };
      {
        --'hrsh7th/nvim-cmp',
        'epheien/nvim-cmp', -- 使用自己的版本
        requires = {
          'hrsh7th/cmp-nvim-lsp',
          'onsails/lspkind.nvim',
          'hrsh7th/cmp-buffer',
          'hrsh7th/cmp-path',
          'epheien/cmp-cmdline',
          --'hrsh7th/vim-vsnip',
          --'hrsh7th/cmp-vsnip',
          'L3MON4D3/LuaSnip',
          'saadparwaiz1/cmp_luasnip',
          'rafamadriz/friendly-snippets',
          --'garymjr/nvim-snippets',
        },
        cond = {event({'InsertEnter'}), keys('n', ';', ':'), keys('n', '/'), keys('n', '?')},
        --cond = cmd('CmpStatus'),
        config = function()
          require('config/nvim-cmp')
        end,
      };
      {
        'ray-x/lsp_signature.nvim',
        cond = keys('n', '<Plug>lsp-signature'),
        config = function()
          require('lsp_signature').setup({
            handler_opts = { border = "single" },
            max_width = 80,
            floating_window_off_x = -1,
            zindex = 2,
          })
        end,
      };
    }
    vim.list_extend(plugins, mac_plugins)
  end

  -- noice
  --if vim.fn.has('nvim-0.10') == 1 then
  --  table.insert(plugins, {
  --    "folke/noice.nvim",
  --    requires = {'MunifTanjim/nui.nvim', 'rcarriga/nvim-notify'},
  --    config = setup_noice,
  --  })
  --end

  table.insert(plugins, {
    "epheien/eagle.nvim",
    cond = cmd('MouseHover'),
    config = function()
      --vim.keymap.del('n', '<MouseMove>')
      vim.o.mousemoveevent = true
      require("eagle").setup({
        --title = ' Mouse Hover ',
        border = 'rounded',
        normal_group = 'Normal',
        detect_idle_timer = 100,
        callback = require('config.mouse_hover').callback,
        --show_lsp_info = false,
      })
      vim.api.nvim_create_user_command('MouseHover', '', {})
    end
  })

  -- dap setup
  table.insert(plugins, {
    "rcarriga/nvim-dap-ui",
    requires = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"},
    cond = cmd('DapuiToggle'),
    config = function()
      require('dapui').setup()
      vim.api.nvim_create_user_command('DapuiToggle', function() require('dapui').toggle() end, {})
    end,
  })
  table.insert(plugins, {
    'mfussenegger/nvim-dap',
    config = function()
      vim.api.nvim_create_user_command('DapHover', function() require"dap.ui.widgets".hover() end, {})
    end
  })
  -- NOTE: 需要调试 nvim lua 的话, 这个插件必须在调试实例无条件加载
  local osv_cond = cmd('DapLuaRunThis')
  if os.getenv('NVIM_DEBUG_LUA') then
    osv_cond = nil
  end
  table.insert(plugins, {
    'jbyuki/one-small-step-for-vimkind',
    requires = {'mfussenegger/nvim-dap'},
    cond = osv_cond,
    config = function()
      local dap = require"dap"
      dap.configurations.lua = {
        {
          type = 'nlua',
          request = 'attach',
          name = "Attach to running Neovim instance",
        }
      }
      dap.adapters.nlua = function(callback, config)
        callback({ type = 'server', host = config.host or "127.0.0.1", port = config.port or 8086 })
      end
      vim.fn.setenv('NVIM_DEBUG_LUA', 1) -- 设置环境变量让 run_this 正常工作
      vim.api.nvim_create_user_command('DapLuaRunThis', function() require"osv".run_this() end, {})
    end
  })

  pckr.add(plugins)
end
setup_pckr()

-- floating window for :help
local help_winid = -1
local create_help_floatwin = function()
  if not vim.api.nvim_win_is_valid(help_winid) then
    local bufid = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(bufid, "bufhidden", "wipe") -- 会被 :h 覆盖掉
    vim.api.nvim_buf_set_option(bufid, "buftype", "help")
    print(vim.api.nvim_buf_get_option(bufid, 'bufhidden'))
    help_winid = vim.api.nvim_open_win(bufid, false, {
      relative = 'editor',
      row = 0,
      col = 0,
      width = vim.o.columns,
      height = math.floor(vim.o.lines / 2),
      border = 'rounded',
    })
    -- BUG: 使用 vim.fn.setwinvar 的话不能正常工作, 而下面的 API 就正常
    vim.api.nvim_win_set_option(help_winid, 'winhighlight', 'Normal:Normal')
  end
  vim.fn.win_gotoid(help_winid)
end
vim.keymap.set('c', '<CR>', function()
  local line = vim.fn.getcmdline()
  local ok, parsed = pcall(vim.api.nvim_parse_cmd, line, {})
  if ok and parsed.cmd == 'help' then
    create_help_floatwin()
  end
  -- fallback
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, true, true), 'cn', false)
end, {silent = true})
vim.keymap.set('n', '<F1>', function()
  create_help_floatwin()
  vim.cmd('help')
end)
vim.keymap.set('i', "<F1>", "<Nop>")

------------------------------------------------------------------------------
-- vim:set fdm=marker fen fdl=0:
