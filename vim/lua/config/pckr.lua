local function setup_pckr()
  local plugins = {
    { 'epheien/pckr.nvim', keys = '<Plug>pckr' }, -- 仅用来管理更新

    'epheien/gruvbox.nvim',

    'drybalka/tree-climber.nvim',

    { 'nvim-treesitter/nvim-treesitter', cmd = 'TSBufToggle', event = 'BufReadPre' },
    {
      'lukas-reineke/indent-blankline.nvim',
      cmd = 'IBLEnable',
      config = function()
        require('ibl').setup()
      end,
    },

    -- 可让你在 nvim buffer 中新增/删除/改名文件的文件管理器
    { 'stevearc/oil.nvim', cmd = 'Oil', opts = {} },

    {
      'neoclide/coc.nvim',
      branch = 'release',
      cmd = 'CocStart',
      requires = { 'Shougo/neosnippet.vim', 'Shougo/neosnippet-snippets' },
    },

    {
      'epheien/vim-gutentags',
      event = { 'BufReadPre' },
      requires = { 'dhananjaylatkar/cscope_maps.nvim' },
    },

    {
      'sakhnik/nvim-gdb',
      run = function()
        vim.cmd('UpdateRemotePlugins')
      end,
      cmd = 'GdbStart',
    },

    {
      'epheien/outline.nvim',
      cmd = { 'Outline', 'OutlineOpen' },
      config = function()
        require('plugins.config.outline')
      end,
      requires = {
        'epheien/outline-ctags-provider.nvim',
        'epheien/outline-treesitter-provider.nvim',
      },
    },

    {
      'windwp/nvim-autopairs',
      event = { 'InsertEnter', 'CmdlineEnter' },
      config = function()
        require('nvim-autopairs').setup({
          map_cr = false,
        })
        require('plugins.config.nvim-autopairs') ---@diagnostic disable-line
      end,
    },

    {
      'epheien/log-highlight.nvim',
      event = 'BufReadPre',
      opts = {},
    },

    -- TODO: 需要实现 BlinkDisable, 现阶段启用后就无法禁用了
    {
      'saghen/blink.cmp',
      tag = 'v0.5.1',
      requires = { 'rafamadriz/friendly-snippets', 'epheien/nvim-cmp' },
      cmd = 'BlinkEnable',
      config = function()
        require('blink.cmp').setup({
          keymap = {
            preset = 'enter', ---@diagnostic disable-line
            ['<C-e>'] = { 'hide', 'fallback' },
            ['<CR>'] = { 'select_and_accept', 'fallback' },
          },
          accept = {
            auto_brackets = {
              enabled = true,
            },
          },
        })
        -- dummy, TODO
        vim.api.nvim_create_user_command('BlinkEnable', function() end, {})
        -- 启用 blink.cmp 的话就禁用掉 nvim-cmp 的编辑文本补全
        vim.cmd('CmpDisable')
      end,
    },

    {
      'preservim/nerdcommenter',
      cmd = 'NERDCommenter',
      keys = { { { 'n', 'x' }, '<Plug>NERDCommenterToggle' } },
      config = function()
        -- dumpy command
        vim.api.nvim_create_user_command('NERDCommenter', function() end, {})
      end,
    },
  }

  -- NOTE: 为了避免无谓的闪烁, 把终端的背景色设置为和 vim/nvim 一致即可
  if vim.env.TERM_PROGRAM == 'Apple_Terminal' then
    table.insert(plugins, 'epheien/bg.nvim')
  end

  -- 事件顺序: BufReadPre => FileType => BufReadPost
  local cmp_plugins = {
    {
      'neovim/nvim-lspconfig',
      event = { 'FileType' },
      config = function()
        require('plugins.config.nvim-lspconfig')
      end,
      requires = { 'ray-x/lsp_signature.nvim' }, -- 需要在 lsp attach 之前加载
    },
    {
      --'hrsh7th/nvim-cmp',
      'epheien/nvim-cmp', -- 使用自己的版本
      requires = {
        'hrsh7th/cmp-nvim-lsp',
        'onsails/lspkind.nvim',
        'epheien/cmp-buffer',
        'hrsh7th/cmp-path',
        'epheien/cmp-cmdline',
        --'hrsh7th/vim-vsnip',
        --'hrsh7th/cmp-vsnip',
        'L3MON4D3/LuaSnip',
        'saadparwaiz1/cmp_luasnip',
        'rafamadriz/friendly-snippets',
        --'garymjr/nvim-snippets',
        --'windwp/nvim-autopairs',
      },
      event = 'InsertEnter',
      cmd = 'CmpDisable',
      keys = { ';', '/', '?' },
      config = function()
        require('plugins.config.nvim-cmp')
        require('luasnip.loaders.from_vscode').lazy_load({
          paths = { vim.fn.stdpath('config') .. '/snippets' },
        })
        vim.keymap.set('n', ';', ':')
        --require('cmp').event:on('confirm_done', require('nvim-autopairs.completion.cmp').on_confirm_done())
      end,
    },
    {
      'ray-x/lsp_signature.nvim',
      keys = '<Plug>lsp-signature',
      opts = {
        handler_opts = { border = nil },
        max_width = 80,
        floating_window_off_x = -1,
        zindex = 2,
      },
    },
  }
  vim.list_extend(plugins, cmp_plugins)

  if vim.fn.has('gui_running') ~= 1 then
    table.insert(plugins, {
      '3rd/image.nvim',
      cmd = 'ImageRender',
      event = { 'BufReadPre', 'InsertEnter' },
      config = function()
        require('image').setup({
          processor = 'magick_cli',
          max_height_window_percentage = 100,
          editor_only_render_when_focused = true,
          tmux_show_only_in_active_window = true,
        })
        vim.api.nvim_create_user_command('ImageRender', function() end, {})
      end,
    })
  end

  table.insert(plugins, {
    'epheien/eagle.nvim',
    cmd = 'MouseHover',
    config = function()
      --vim.keymap.del('n', '<MouseMove>')
      vim.o.mousemoveevent = true
      require('eagle').setup({
        --title = ' Mouse Hover ',
        border = 'rounded',
        normal_group = 'Normal',
        detect_idle_timer = 100,
        callback = require('config.mouse_hover').callback,
        --show_lsp_info = false,
      })
      vim.api.nvim_create_user_command('MouseHover', '', {})
    end,
  })

  -- dap setup
  table.insert(plugins, {
    'rcarriga/nvim-dap-ui',
    requires = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' },
    cmd = 'DapuiToggle',
    config = function()
      require('dapui').setup()
      vim.api.nvim_create_user_command('DapuiToggle', function()
        require('dapui').toggle()
      end, {})
    end,
  })
  table.insert(plugins, {
    'mfussenegger/nvim-dap',
    cmd = 'DapToggleBreakpoint',
    config = function()
      vim.api.nvim_create_user_command('DapHover', function()
        require('dap.ui.widgets').hover()
      end, {})
    end,
  })
  -- NOTE: 需要调试 nvim lua 的话, 这个插件必须在调试实例无条件加载
  table.insert(plugins, {
    'jbyuki/one-small-step-for-vimkind',
    requires = { 'mfussenegger/nvim-dap' },
    cmd = os.getenv('NVIM_DEBUG_LUA') and nil or 'DapLuaRunThis',
    config = function()
      local dap = require('dap')
      dap.configurations.lua = {
        {
          type = 'nlua',
          request = 'attach',
          name = 'Attach to running Neovim instance',
        },
      }
      dap.adapters.nlua = function(callback, config)
        callback({ type = 'server', host = config.host or '127.0.0.1', port = config.port or 8086 })
      end
      vim.fn.setenv('NVIM_DEBUG_LUA', 1) -- 设置环境变量让 run_this 正常工作
      vim.api.nvim_create_user_command('DapLuaRunThis', function()
        require('osv').run_this()
      end, {})
    end,
  })

  -- gitsigns 有严重的性能问题, 严重影响 lazygit 的使用体验, 暂时不用
  --table.insert(plugins, {
  --  'lewis6991/gitsigns.nvim',
  --  cond = cmd('Gitsigns'),
  --  config = function()
  --    local gitsigns = require('gitsigns')
  --    gitsigns.setup({
  --      watch_gitdir = {
  --        enable = false,
  --      },
  --      preview_config = {
  --        border = { "", "", "", { " ", 'NormalFloat' }, "", "", "", { " ", 'NormalFloat' } },
  --      },
  --    })
  --    vim.keymap.set('n', ']c', function() gitsigns.nav_hunk('next', {wrap = false}) end)
  --    vim.keymap.set('n', '[c', function() gitsigns.nav_hunk('prev', {wrap = false}) end)
  --  end
  --})

  table.insert(plugins, {
    'echasnovski/mini.diff',
    event = 'FileType',
    opts = {
      view = {
        style = 'sign',
        --signs = { add = '+', change = '~', delete = '_' },
        signs = { add = '┃', change = '┃', delete = '_' },
      },
      mappings = {
        goto_prev = '[c',
        goto_next = ']c',
      },
    },
  })

  -- 支持鼠标拖动浮窗
  table.insert(plugins, {
    'epheien/flirt.nvim',
    event = 'BufWinEnter',
    config = function()
      local flirt = require('flirt')
      flirt.setup({
        override_open = false,
        close_command = nil,
        default_move_mappings = false,
      })
      -- 浮动窗口不能用鼠标拖选了
      vim.keymap.set('n', '<LeftDrag>', function()
        if vim.fn.win_gettype() == 'popup' then
          vim.schedule(flirt.on_drag)
        else
          return '<LeftDrag>'
        end
      end, { silent = true, expr = true })
    end,
  })

  -- 显示 LSP 进度
  table.insert(plugins, { 'j-hui/fidget.nvim', event = 'BufReadPre', opts = {} })

  table.insert(plugins, { 'kshenoy/vim-signature', event = 'BufReadPre' })
  --table.insert(plugins, { 'b0o/incline.nvim', config = require('plugins/config/incline') })
  table.insert(plugins, { 'norcalli/nvim-colorizer.lua', cmd = 'ColorizerToggle' })

  table.insert(plugins, {
    'dstein64/nvim-scrollview',
    config = function()
      vim.api.nvim_set_hl(0, 'ScrollViewDiagnosticsHint', { link = 'DiagnosticHint' })
      vim.api.nvim_set_hl(0, 'ScrollViewDiagnosticsInfo', { link = 'DiagnosticInfo' })
      vim.api.nvim_set_hl(0, 'ScrollViewDiagnosticsWarn', { link = 'DiagnosticWarn' })
      vim.api.nvim_set_hl(0, 'ScrollViewDiagnosticsError', { link = 'DiagnosticError' })
      vim.api.nvim_set_hl(0, 'ScrollViewHover', { link = 'PmenuSel' })
      vim.api.nvim_set_hl(0, 'ScrollViewRestricted', { link = 'ScrollView' })
    end,
  })

  table.insert(plugins, {
    'folke/edgy.nvim',
    config = function()
      --vim.opt.splitkeep = "screen"
      require('edgy').setup({
        close_when_all_hidden = false,
        wo = {
          statusline = '─',
          winfixbuf = true,
        },
        options = {
          left = { size = 36 },
          bottom = { size = 10 },
          right = { size = 30 },
          top = { size = 10 },
        },
        animate = {
          enabled = false,
        },
        left = {
          {
            ft = 'NvimTree',
            --pinned = true,
            open = 'NvimTreeOpen',
          },
          {
            ft = 'neo-tree',
            open = 'Neotree',
          },
          {
            ft = 'tagbar',
            open = 'TagbarOpen',
          },
          {
            ft = 'aerial',
            open = 'AerialOpen',
          },
          {
            title = function()
              return 'Outline'
            end,
            ft = 'Outline',
            open = 'OutlineOpen',
          },
        },
      })
      vim.api.nvim_set_hl(0, 'EdgyNormal', { link = 'Normal' })
    end,
  })

  table.insert(plugins, {
    'rbong/vim-flog',
    requires = {
      'tpope/vim-fugitive',
    },
    cmd = { 'Flog', 'Git' },
  })

  table.insert(plugins, {
    'williamboman/mason.nvim',
    cmd = 'Mason',
    opts = {},
  })
  -- 手动更新 PATH, 避免载入 mason.nvim
  vim.env.PATH = vim.fn.stdpath('data') .. '/mason/bin' .. ':' .. vim.env.PATH

  -- NOTE: 官方不推荐使用懒加载的方式, 容易出现奇怪的问题
  -- TODO: 想办法实现懒加载
  table.insert(plugins, {
    'andymass/vim-matchup',
    config = function()
      vim.g.matchup_matchparen_offscreen = {}
    end,
  })

  table.insert(plugins, {
    'nvchad/menu',
    keys = { 'Z', '<RightRelease>' },
    config = function()
      local callback = function(mouse)
        return function()
          local menu_exists = #require('menu.state').bufids > 0
          if menu_exists then
            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
              local buf = vim.api.nvim_win_get_buf(win)
              if vim.bo[buf].filetype == 'NvMenu' then
                vim.api.nvim_win_close(win, true)
              end
            end
          end
          local options = vim.bo.ft == 'NvimTree' and 'nvimtree' or 'mydef'
          require('menu').open(options, { mouse = mouse, border = false })
        end
      end
      vim.keymap.set('n', '<RightRelease>', callback(true), {})
      vim.keymap.set('n', 'Z', callback(false), { nowait = true })
      vim.o.mousemodel = 'extend'
    end,
    requires = { 'nvchad/volt' },
  })

  -- 在 nvim 内直接预览 markdown, 效果凑合可用
  table.insert(plugins, {
    'OXY2DEV/markview.nvim',
    ft = 'markdown',
    opts = {
      --initial_state = false,
      code_blocks = {
        sign = false,
      },
      headings = {
        heading_1 = {
          sign = '',
        },
        heading_2 = {
          sign = '',
        },
        heading_3 = {
          sign = '',
        },
        setext_1 = {
          sign = '',
        },
        setext_2 = {
          sign = '',
        },
      },
    },
    requires = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
  })

  table.insert(plugins, {
    'folke/todo-comments.nvim',
    event = 'FileType',
    config = function()
      require('todo-comments').setup({
        signs = false,
        highlight = {
          multiline = false,
          pattern = [[.*\s<(KEYWORDS)>\s*]], -- vim regex with prefix '\v\C'
        },
        search = {
          pattern = [[\b(KEYWORDS)\b]], -- ripgrep regex
        },
      })
      local keywords = { 'TODO', 'FIXME' }
      vim.keymap.set('n', ']t', function()
        require('todo-comments').jump_next({ keywords = keywords })
      end, { desc = 'Next todo comment' })
      vim.keymap.set('n', '[t', function()
        require('todo-comments').jump_prev({ keywords = keywords })
      end, { desc = 'Prev todo comment' })
    end,
    requires = { 'nvim-lua/plenary.nvim' },
  })

  table.insert(plugins, {
    'stevearc/conform.nvim',
    cmd = 'Format',
    config = function()
      local conform = require('conform')
      conform.setup({
        formatters_by_ft = {
          lua = { 'stylua', lsp_format = 'fallback' },
          cpp = { 'clang-format' },
        },
        format_on_save = function() end,
        format_after_save = function() end,
      })

      vim.api.nvim_create_user_command('Format', function(args)
        local range = nil
        if args.count ~= -1 then
          local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
          range = {
            start = { args.line1, 0 },
            ['end'] = { args.line2, end_line:len() },
          }
        end
        conform.format({ async = true, lsp_format = 'fallback', range = range })
      end, { range = true })
    end,
  })

  table.insert(plugins, {
    'tpope/vim-scriptease',
    cmd = 'BreakAdd',
  })

  table.insert(plugins, {
    'oskarrrrrrr/symbols.nvim',
    cmd = 'SymbolsToggle',
    config = function()
      local r = require('symbols.recipes')
      require('symbols').setup(r.DefaultFilters, r.AsciiSymbols, {
        -- custom settings here
        -- e.g. hide_cursor = false
      })
    end,
  })

  table.insert(plugins, {
    'ojroques/vim-oscyank',
    cmd = { 'OSCYankVisual', 'OSCYank' },
  })

  table.insert(plugins, { 'epheien/termdbg', cmd = 'Termdbg' })

  -- 载入 plugins 目录的插件
  vim.list_extend(plugins, require('plugins'))

  require('utils').add_plugins(plugins)
end

setup_pckr()
