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
      cond = keys('n', '<Plug>lualine'),
      config = function() require('config/lualine') end,
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

    {'stevearc/aerial.nvim', cond = cmd('AerialToggle'), config = function() require('config/aerial') end};
    {'nvim-treesitter/nvim-treesitter', cond = {cmd('TSBufToggle'), event('BufReadPre')}};
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

    {
      "hedyhli/outline.nvim",
      cond = {cmd('Outline'), cmd('OutlineOpen')},
      config = function() require('config/outline') end,
    },
  }

  if true then
    -- 事件顺序: BufReadPre => FileType => BufReadPost
    local mac_plugins = {
      {
        "neovim/nvim-lspconfig",
        cond = event({'FileType'}),
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
        cond = {event({'InsertEnter'}), keys('n', ';'), keys('n', '/'), keys('n', '?'), cmd('CmpDisable')},
        --cond = cmd('CmpStatus'),
        config = function()
          require('config/nvim-cmp')
          vim.keymap.set('n', ';', ':')
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
    cond = cmd('DapToggleBreakpoint'),
    config = function()
      vim.api.nvim_create_user_command('DapHover', function() require"dap.ui.widgets".hover() end, {})
    end
  })
  -- NOTE: 需要调试 nvim lua 的话, 这个插件必须在调试实例无条件加载
  table.insert(plugins, {
    'jbyuki/one-small-step-for-vimkind',
    requires = {'mfussenegger/nvim-dap'},
    cond = os.getenv('NVIM_DEBUG_LUA') and nil or cmd('DapLuaRunThis'),
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
        preview_config = {
          border = { "", "", "", { " ", 'NormalFloat' }, "", "", "", { " ", 'NormalFloat' } },
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

  table.insert(plugins, {
    'j-hui/fidget.nvim',
    cond = event('BufReadPre'),
    config = function()
      require('fidget').setup({})
    end
  })

  table.insert(plugins, { 'kshenoy/vim-signature', cond = event("BufReadPre") })
  --table.insert(plugins, { 'b0o/incline.nvim', config = require('config/incline') })
  table.insert(plugins, { 'norcalli/nvim-colorizer.lua', cond = cmd('ColorizerToggle') })

  table.insert(plugins, {
    'dstein64/nvim-scrollview',
    config = function()
      vim.api.nvim_set_hl(0, 'ScrollViewDiagnosticsHint', { link = 'DiagnosticHint' })
      vim.api.nvim_set_hl(0, 'ScrollViewDiagnosticsInfo', { link = 'DiagnosticInfo' })
      vim.api.nvim_set_hl(0, 'ScrollViewDiagnosticsWarn', { link = 'DiagnosticWarn' })
      vim.api.nvim_set_hl(0, 'ScrollViewDiagnosticsError', { link = 'DiagnosticError' })
    end
  })

  table.insert(plugins, {
    'folke/edgy.nvim',
    config = function()
      vim.opt.splitkeep = "screen"
      require('edgy').setup({
        close_when_all_hidden = false,
        wo = {
          statusline = '─',
        },
        left = {
          {
            ft = 'NvimTree',
            pinned = true,
            open = 'NvimTreeOpen',
          },
          {
            ft = "tagbar",
            open = "TagbarOpen",
          },
          {
            title = function() return 'Outline' end,
            ft = "Outline",
            open = "OutlineOpen",
          },
        },
      })
      vim.api.nvim_set_hl(0, 'EdgyNormal', { link = 'Normal' })
    end
  })

  table.insert(plugins, {
    'rbong/vim-flog',
    requires = {
      'tpope/vim-fugitive',
    },
    cond = cmd('Flog'),
  })

  table.insert(plugins, {
    'williamboman/mason.nvim',
    cond = cmd('Mason'),
    config = function () require('mason').setup() end,
  })
  -- 手动更新 PATH, 避免载入 mason.nvim
  vim.env.PATH = vim.fn.stdpath('data') .. '/mason/bin' .. ':' .. vim.env.PATH

  pckr.add(plugins)
end
-- }}}
setup_pckr()

-- floating window for :help {{{
local help_winid = -1
local create_help_floatwin = function()
  if not vim.api.nvim_win_is_valid(help_winid) then
    local bufid = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = bufid }) -- 会被 :h 覆盖掉
    vim.api.nvim_set_option_value("buftype", "help", { buf = bufid })
    local width = math.min(vim.o.columns, 100)
    local col = math.floor((vim.o.columns - width) / 2)
    help_winid = vim.api.nvim_open_win(bufid, false, {
      relative = 'editor',
      row = 1,
      col = col,
      width = width,
      height = math.floor(vim.o.lines / 2),
      border = 'rounded',
    })
    -- BUG: 使用 vim.fn.setwinvar 的话不能正常工作, 而下面的 API 就正常
    vim.api.nvim_set_option_value('winhighlight', 'Normal:Normal', { win = help_winid })
  end
  vim.fn.win_gotoid(help_winid)
end
vim.keymap.set('c', '<CR>', function()
  local line = vim.fn.getcmdline()
  local ok, parsed = pcall(vim.api.nvim_parse_cmd, line, {})
  if not ok then
    return '<CR>'
  end
  if parsed.cmd == 'help' then
    vim.schedule(function()
      create_help_floatwin()
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, true, true), 'cn', false)
    end)
    return ''
  end
  return '<CR>'
end, {silent = true, expr = true})
vim.keymap.set('n', '<F1>', function()
  create_help_floatwin()
  vim.cmd('help')
end)
vim.keymap.set('i', "<F1>", "<Nop>")
-- }}}

-- 手动修正 Alacritty 终端模拟器鼠标点击时, 光标仍然闪烁的问题 {{{
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
local TERM_PROGRAM = os.getenv('TERM_PROGRAM')
if not (TERM_PROGRAM == 'kitty' or TERM_PROGRAM == 'iTerm' or
      TERM_PROGRAM == 'Apple_Terminal' or vim.fn.has('gui_running') == 1) then
  setup_on_key()
end
-- }}}

-- MyStatusLine, 简易实现以提高载入速度 {{{
local function create_transitional_hl(left, right)
  local name = left
  local opts = vim.api.nvim_get_hl(0, { name = name, link = false })
  if not vim.tbl_isempty(vim.api.nvim_get_hl(0, { name = name .. 'Reverse' })) then
    return false -- 已存在的话就忽略
  end
  if vim.tbl_isempty(opts) then
    return false
  end
  local right_opts = vim.api.nvim_get_hl(0, { name = right, link = false })
  opts = vim.tbl_deep_extend('force', opts, { reverse = opts.reverse and false or true, fg = right_opts.bg or 'NONE' })
  vim.api.nvim_set_hl(0, name .. 'Reverse', opts)
  return true
end

local function status_line_theme_gruvbox()
  vim.api.nvim_set_hl(0, 'MyStlNormal', { fg = '#a89984', bg = '#504945' }) -- 246 239
  vim.api.nvim_set_hl(0, 'MyStlNormalNC', { fg = '#7c6f64', bg = '#3c3836' }) -- 243 237
  vim.api.nvim_set_hl(0, 'MyStlNormalMode', { fg = '#282828', bg = '#a89984' }) -- 235 246
  vim.api.nvim_set_hl(0, 'MyStlInsertMode', { fg = '#282828', bg = '#83a598' }) -- 235 109
  vim.api.nvim_set_hl(0, 'MyStlVisualMode', { fg = '#282828', bg = '#fe8019' }) -- 235 208
  vim.api.nvim_set_hl(0, 'MyStlReplaceMode', { fg = '#282828', bg = '#8ec07c' }) -- 235 108
  create_transitional_hl('MyStlNormal', 'Normal')
  create_transitional_hl('MyStlNormalNC', 'Normal')
end

local function status_line_theme_mywombat()
  vim.api.nvim_set_hl(0, 'MyStlNormal', { fg = '#282828', bg = '#8ac6f2', ctermfg = 235, ctermbg = 117 })
  vim.api.nvim_set_hl(0, 'MyStlNormalNC', { fg = '#303030', bg = '#6a6a6a', ctermfg = 236, ctermbg = 242 })
  vim.api.nvim_set_hl(0, 'MyStlNormalMode', { fg = '#282828', bg = '#eeee00', ctermfg = 235, ctermbg = 226, bold = true })
  vim.api.nvim_set_hl(0, 'MyStlInsertMode', { fg = '#282828', bg = '#95e454', ctermfg = 235, ctermbg = 119, bold = true })
  vim.api.nvim_set_hl(0, 'MyStlVisualMode', { fg = '#282828', bg = '#f2c68a', ctermfg = 235, ctermbg = 216, bold = true })
  vim.api.nvim_set_hl(0, 'MyStlReplaceMode', { fg = '#282828', bg = '#e5786d', ctermfg = 235, ctermbg = 203, bold = true })
  create_transitional_hl('MyStlNormal', 'Normal')
  create_transitional_hl('MyStlNormalNC', 'Normal')
end

local stl_hl_map = {
  I       = 'MyStlInsertMode',
  T       = 'MyStlInsertMode',
  V       = 'MyStlVisualMode',
  S       = 'MyStlVisualMode',
  R       = 'MyStlReplaceMode',
  ['\22'] = 'MyStlVisualMode',
  ['\19'] = 'MyStlVisualMode',
}
local mode_table = require('config/mystl').mode_table
local trail_glyph = vim.fn.OnlyASCII() == 1 and '' or ''
function MyStatusLine()
  local m = vim.api.nvim_get_mode().mode
  local mode = 'NORMAL'
  if m ~= 'n' then
    mode = mode_table[m] or m:upper()
  end
  local active = tonumber(vim.g.actual_curwin) == vim.api.nvim_get_current_win()
  local mod = vim.o.modified and ' [+]' or ''
  if active then
    local mode_group = stl_hl_map[m:upper():sub(1, 1)] or 'MyStlNormalMode'
    return ('%#' .. mode_group .. '# ' .. mode ..
      ' %#MyStlNormal# %f' .. mod .. ' │ %l/%L,%v %#MyStlNormalReverse#'
      .. trail_glyph .. '%#StatusLine#')
  else
    return '%#MyStlNormalNC# %f' .. mod .. ' │ %l/%L,%v %#MyStlNormalNCReverse#' .. trail_glyph .. '%#StatusLineNC#'
  end
end

-- init MyStatusLine
local mystl_theme = status_line_theme_mywombat
mystl_theme()
vim.api.nvim_create_autocmd('ColorScheme', {callback = mystl_theme})
vim.opt.laststatus = 2
vim.opt.showmode = false
vim.opt.statusline = '%{%v:lua.MyStatusLine()%}'
-- :pwd<CR> 的时候会不及时刷新, 所以需要添加这个自动命令
vim.api.nvim_create_autocmd('ModeChanged', { callback = function() vim.cmd.redrawstatus() end })
-- 修正 quickfix 窗口的状态栏
vim.api.nvim_create_autocmd('BufReadPost', {
  callback = function()
    local stl = vim.opt_local.statusline:get()
    if stl ~= '' and stl ~= '─' then
      vim.opt_local.statusline = ''
    end
  end
})
-- }}}

-- 增强 <C-g> 显示的信息 {{{
vim.keymap.set('n', '<C-g>', function()
  local msg_list = {}
  local fname = vim.fn.expand('%:p')
  table.insert(msg_list, fname ~= '' and fname or vim.api.nvim_eval_statusline('%f', {}).str)
  if vim.api.nvim_eval_statusline('%w', {}).str ~= '' then
    table.insert(msg_list, vim.api.nvim_eval_statusline('%w', {}).str)
  end
  if vim.o.readonly then
    table.insert(msg_list, '[RO]')
  end
  if vim.o.filetype ~= '' then
    table.insert(msg_list, string.format('[%s]', vim.o.filetype))
  end
  if vim.o.fileformat ~= '' then
    table.insert(msg_list, string.format('[%s]', vim.o.fileformat))
  end
  if vim.o.fileencoding ~= '' then
    table.insert(msg_list, string.format('[%s]', vim.o.fileencoding))
  end
  if fname ~= '' and vim.fn.filereadable(fname) == 1 then
    table.insert(msg_list, vim.fn.strftime("%Y-%m-%d %H:%M:%S", vim.fn.getftime(fname)))
  end
  vim.cmd.echo(vim.fn.string(vim.fn.join(msg_list, ' ')))
end)
-- }}}

------------------------------------------------------------------------------
-- vim:set fdm=marker fen fdl=0:
