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

local function setup_noice() -- {{{
  lazysetup('noice', {
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
    },
    presets = {
      bottom_search = true, -- use a classic bottom cmdline for search
      command_palette = true, -- position the cmdline and popupmenu together
      long_message_to_split = true, -- long messages will be sent to a split
      inc_rename = false, -- enables an input dialog for inc-rename.nvim
      lsp_doc_border = false, -- add a border to hover docs and signature help
    },
    lsp = {
      signature = {
        enabled = false,
      }
    },
    popupmenu = {
      enabled = false,
    },
    notify = {
      enabled = false,
    },
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
      enabled = true,
      format = {
        help = false,
        lua = false,
        filter = false,
        --search_down = { icon = "/ ⌄" },
        --search_up = { icon = "? ⌃" },
      },
    },
    messages = {
      enabled = true, -- false 会使用 cmdline, 可避免闪烁
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

local function setup_lualine() -- {{{
  local theme = {
    normal = {
      a = { fg = '#282828', bg = '#8ac6f2' }, -- "模式 文件 | 位置" 后两者的颜色
      c = { fg = "#665c54", bg = "NONE" }, -- 填充色
    },
    inactive = { a = { fg = '#282828', bg = '#6a6a6a' } },
  }
  local color_map = {
    i = { fg = '#282828', bg = '#95e454' },
    t = { fg = '#282828', bg = '#95e454' },
    v = { fg = '#282828', bg = '#f2c68a' },
    s = { fg = '#282828', bg = '#f2c68a' },
    r = { fg = '#282828', bg = '#e5786d' },
  }
  local mode_color = function()
    return color_map[vim.fn.mode():sub(1, 1):lower()] or { fg = '#282828', bg = '#e0e000' }
  end
  local location = function()
    return vim.api.nvim_eval_statusline('%l/%L,%v', {winid = vim.fn.win_getid()})['str']
  end
  local opts = {
    options = {
      component_separators = { left = '│', right = '│' },
      theme = theme,
    },
    sections = {
      lualine_a = { { 'mode', separator = '', color = mode_color}, 'filename', location },
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {},
    },
    inactive_sections = {
      lualine_a = { 'filename', location },
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {}
    },
    tabline = {},
    winbar = {},
  }
  require('lualine').setup(opts)
end
-- }}}

-- ======================================================================
-- 以下开始是 pckr.nvim 管理的插件
-- ======================================================================
local function setup_pckr() -- {{{
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
    {
      'nvim-lualine/lualine.nvim',
      config = function()
        vim.opt.laststatus = 2
        vim.opt.showmode = false
        setup_lualine()
      end
    };

    -- telescope
    {
      'nvim-telescope/telescope.nvim',
      tag = '0.1.8',
      requires = {'nvim-lua/plenary.nvim', 'debugloop/telescope-undo.nvim', 'nvim-tree/nvim-web-devicons'},
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

    {'sakhnik/nvim-gdb', run = function() vim.cmd('UpdateRemotePlugins') end, cond = cmd('GdbStart')};

  }

  -- 暂时只在 macOS 试验性地使用 nvim-cmp 和 nvim-lspconfig
  if vim.fn.has('mac') == 1 then
    -- 事件顺序: BufReadPre => FileType => BufReadPost
    local mac_plugins = {
      {
        "neovim/nvim-lspconfig",
        cond = event({'FileType'}), -- 这里 BufReadPre 先载入, 配置用 FileType 触发
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
        cond = {event({'InsertEnter'}), keys('n', ';', ':'), keys('n', '/'), keys('n', '?'), cmd('CmpDisable')},
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
            handler_opts = { border = nil },
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

  table.insert(plugins, {
    'lewis6991/gitsigns.nvim',
    cond = cmd('Gitsigns'),
    config = function()
      local gitsigns = require('gitsigns')
      gitsigns.setup({
        signs = {
          add          = { text = '┃' },
          change       = { text = '┃' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
      })
      vim.keymap.set('n', ']c', function() gitsigns.nav_hunk('next', {wrap = false}) end)
      vim.keymap.set('n', '[c', function() gitsigns.nav_hunk('prev', {wrap = false}) end)
    end
  })

  table.insert(plugins, {
    'epheien/flirt.nvim',
    cond = event('BufWinEnter'),
    config = function()
      local flirt = require('flirt')
      flirt.setup({
        override_open = false,
        close_command = nil,
        default_move_mappings = false,
      })
      -- 浮动窗口不能用鼠标拖选了
      vim.keymap.set('n', '<LeftDrag>', function()
        if vim.fn.win_gettype() == "popup" then
          vim.schedule(flirt.on_drag)
        else
          return '<LeftDrag>'
        end
      end, { silent = true, expr = true })
    end
  })

  --table.insert(plugins, { 'b0o/incline.nvim', config = require('config/incline') })
  table.insert(plugins, { 'dstein64/nvim-scrollview' })
  table.insert(plugins, { 'norcalli/nvim-colorizer.lua', cond = cmd('ColorizerToggle') })

  pckr.add(plugins)
end
-- }}}
setup_pckr()

-- floating window for :help {{{
local help_winid = -1
local create_help_floatwin = function()
  if not vim.api.nvim_win_is_valid(help_winid) then
    local bufid = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(bufid, "bufhidden", "wipe") -- 会被 :h 覆盖掉
    vim.api.nvim_buf_set_option(bufid, "buftype", "help")
    local width = math.min(vim.o.columns, 86)
    col = math.floor((vim.o.columns - width) / 2)
    help_winid = vim.api.nvim_open_win(bufid, false, {
      relative = 'editor',
      row = 1,
      col = col,
      width = width,
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
    vim.schedule(function()
      create_help_floatwin()
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, true, true), 'cn', false)
    end)
    return ''
  end
  -- fallback
  return '<CR>'
end, {silent = true, expr = true})
vim.keymap.set('n', '<F1>', function()
  create_help_floatwin()
  vim.cmd('help')
end)
vim.keymap.set('i', "<F1>", "<Nop>")
-- }}}

-- 手动修正 Alacritty 终端模拟器鼠标点击时, 光标仍然闪烁的问题
local inited_on_key = false
local setup_on_key = function()
  if inited_on_key then
    return
  end
  inited_on_key = true
  local prs = vim.keycode("<LeftMouse>")
  local rel = vim.keycode("<LeftRelease>")
  local cursor_blinkon_opt = { "n-v-c:block", "i-ci-ve:ver25", "r-cr:hor20", "o:hor50",
    "a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor", "sm:block-blinkwait175-blinkoff150-blinkon175" }
  local cursor_blinkoff_opt = { "n-v-c:block", "i-ci-ve:ver25", "r-cr:hor20", "o:hor50",
    "a:Cursor/lCursor", "sm:block-blinkwait175-blinkoff150-blinkon175" }
  vim.on_key(function(k)
    if k == prs then
      vim.opt.guicursor = cursor_blinkoff_opt
    elseif k == rel then
      vim.opt.guicursor = cursor_blinkon_opt
    end
  end)
end
vim.api.nvim_create_user_command('FixMouseClick', function()
  setup_on_key()
end, {nargs = 0})
-- 暂时所知仅 Alacritty 需要修正
if os.getenv('TERM_PROGRAM') == 'alacritty' then
  setup_on_key()
end

------------------------------------------------------------------------------
-- vim:set fdm=marker fen fdl=0:
