local function core_plugins()
  local plugins = {
    { 'folke/lazy.nvim', lazy = true },

    { 'drybalka/tree-climber.nvim', lazy = true },

    { 'nvim-lua/plenary.nvim', cmd = { 'PlenaryBustedFile', 'PlenaryBustedDirectory' } },

    {
      'epheien/dressing.nvim',
      event = 'VeryLazy',
      opts = {
        input = {
          border = 'single',
          win_options = {
            winhighlight = 'NormalFloat:Normal',
          },
          mappings = {
            i = {
              ['<CR>'] = function()
                if vim.fn.pumvisible() == 1 or require('cmp').visible() then
                  require('plugins.config.nvim-cmp').confirm({
                    select = false,
                    behavior = require('cmp').ConfirmBehavior.Insert,
                  })()
                else
                  vim.cmd([[call feedkeys("\<C-s>", 'm')]])
                end
              end,
              ['<C-s>'] = 'Confirm',
              ['<Up>'] = false,
              ['<Down>'] = false,
              ['<C-p>'] = 'HistoryPrev',
              ['<C-n>'] = 'HistoryNext',
            },
          },
        },
        select = {
          backend = {
            'telescope',
            'builtin',
          },
          builtin = {
            border = 'single',
            win_options = {
              wrap = false,
              winhighlight = 'MatchParen:,NormalFloat:Normal',
            },
            mappings = {
              ['q'] = 'Close',
            },
            override = function(conf)
              if vim.startswith(conf.title, ' Permit opencode to: ') then
                -- 默认窗口高度是 10, 考虑上 border 以及奇数
                conf.row = conf.row + 6
              end
              return conf
            end,
          },
          get_config = function(opts)
            if vim.startswith(opts.prompt, 'Permit opencode to: ') then
              return {
                backend = 'builtin',
              }
            end
          end,
        },
      },
    },

    { 'nvim-treesitter/nvim-treesitter', cmd = 'TSBufToggle', event = 'BufReadPre' },
    {
      'lukas-reineke/indent-blankline.nvim',
      cmd = 'IBLEnable',
      config = function() require('ibl').setup() end,
    },

    -- 可让你在 nvim buffer 中新增/删除/改名文件的文件管理器
    { 'stevearc/oil.nvim', cmd = 'Oil', opts = {} },

    {
      'neoclide/coc.nvim',
      branch = 'release',
      cmd = 'CocStart',
      dependencies = { 'Shougo/neosnippet.vim', 'Shougo/neosnippet-snippets' },
    },

    {
      'epheien/vim-gutentags',
      event = { 'BufReadPre' },
      dependencies = { 'dhananjaylatkar/cscope_maps.nvim' },
    },

    {
      'sakhnik/nvim-gdb',
      run = function() vim.cmd('UpdateRemotePlugins') end,
      cmd = 'GdbStart',
    },

    {
      'epheien/outline.nvim',
      cmd = { 'Outline', 'OutlineToggleFloat' },
      config = function() require('plugins.config.outline') end,
      dependencies = {
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

    {
      'preservim/nerdcommenter',
      cmd = 'NERDCommenter',
      keys = { { '<Plug>NERDCommenterToggle', mode = { 'n', 'x' } } },
      config = function()
        -- dumpy command
        vim.api.nvim_create_user_command('NERDCommenter', function() end, {})
      end,
    },
  }

  -- NOTE: 为了避免无谓的闪烁, 把终端的背景色设置为和 vim/nvim 一致即可
  if vim.env.TERM_PROGRAM == 'Apple_Terminal' or vim.env.TERM_PROGRAM == 'ghostty' then
    table.insert(plugins, 'epheien/bg.nvim')
  end

  -- NOTE: 打开 markdown 的时候可能导致卡死, 例如 glrnvim 的 README.md
  -- NOTE: tmux 环境下使用 image.nvim 问题多多, 主要是不能自动消失, 所以暂时禁用
  if not vim.env.TMUX and vim.fn.has('gui_running') ~= 1 then
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
          integrations = {
            markdown = {
              enabled = true,
              clear_in_insert_mode = false,
              download_remote_images = false,
              only_render_image_at_cursor = false,
              -- if true, images will be rendered in floating markdown windows
              floating_windows = true,
              filetypes = { 'markdown', 'vimwiki' },
            },
          },
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
    dependencies = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' },
    cmd = 'DapuiToggle',
    config = function()
      require('dapui').setup()
      vim.api.nvim_create_user_command('DapuiToggle', function() require('dapui').toggle() end, {})
    end,
  })
  table.insert(plugins, {
    'mfussenegger/nvim-dap',
    cmd = 'DapToggleBreakpoint',
    config = function()
      vim.api.nvim_create_user_command(
        'DapHover',
        function() require('dap.ui.widgets').hover() end,
        {}
      )
    end,
  })
  -- NOTE: 需要调试 nvim lua 的话, 这个插件必须在调试实例无条件加载
  table.insert(plugins, {
    'jbyuki/one-small-step-for-vimkind',
    dependencies = { 'mfussenegger/nvim-dap' },
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
      vim.fn.setenv('NVIM_DEBUG_LUA', '1') -- 设置环境变量让 run_this 正常工作
      vim.api.nvim_create_user_command(
        'DapLuaRunThis',
        function() require('osv').run_this() end,
        {}
      )
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

  -- 支持鼠标拖动浮窗
  table.insert(plugins, {
    'epheien/flirt.nvim',
    event = 'VeryLazy',
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

  table.insert(plugins, {
    'kshenoy/vim-signature',
    event = 'BufReadPre',
    config = function() vim.api.nvim_set_hl(0, 'SignatureMarkText', { link = 'Identifier' }) end,
  })
  table.insert(plugins, { 'norcalli/nvim-colorizer.lua', cmd = 'ColorizerToggle' })

  table.insert(plugins, {
    'dstein64/nvim-scrollview',
    event = 'VeryLazy',
    config = function() end,
  })

  table.insert(plugins, {
    'folke/edgy.nvim',
    enabled = false,
    event = 'VeryLazy',
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
            ft = 'ConnManager',
            open = 'ConnManager open',
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
            title = function() return 'Outline' end,
            ft = 'Outline',
            open = 'OutlineOpen',
          },
        },
      })
    end,
  })

  table.insert(plugins, {
    'rbong/vim-flog',
    dependencies = {
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
    lazy = true, -- 暂时禁用 matchup, 平时没有使用它的独有功能
    config = function() vim.g.matchup_matchparen_offscreen = {} end,
  })

  table.insert(plugins, {
    'nvchad/menu',
    keys = { 'Z', '<RightRelease>' },
    config = function()
      local callback = function(mouse)
        local mapping = {
          NvimTree = 'nvimtree',
          ConnManager = 'conn-manager',
        }
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
          local options = mapping[vim.bo.ft] or 'mydef'
          require('menu').open(options, { mouse = mouse, border = false })
        end
      end
      vim.keymap.set('n', '<RightRelease>', callback(true), {})
      vim.keymap.set('n', 'Z', callback(false), { nowait = true })
      vim.o.mousemodel = 'extend'
    end,
    dependencies = { 'epheien/volt' },
  })

  -- 在 nvim 内直接预览 markdown, 效果凑合可用
  table.insert(plugins, {
    'OXY2DEV/markview.nvim',
    ft = 'markdown',
    opts = {
      preview = {
        enable = false,
      },
      code_blocks = {
        sign = false,
      },
      markdown = {
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
    },
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
  })

  table.insert(plugins, {
    'folke/todo-comments.nvim',
    event = 'FileType',
    config = function()
      -- NOTE: todo-comments 会从已有的高亮组中自动生成高亮组,
      --       所以必须确保 DiagnosticXXX 系列的高亮组已经全部载入
      vim.api.nvim_exec_autocmds('User', { modeline = false, pattern = 'MyLazyEvent' })
      require('todo-comments').setup({
        signs = false,
        highlight = {
          multiline = false,
          pattern = [[.*\s<(KEYWORDS)>\s*]], -- vim regex with prefix '\v\C'
          after = '',
        },
        search = {
          pattern = [[\b(KEYWORDS)\b]], -- ripgrep regex
        },
      })
      local keywords = { 'TODO', 'FIXME' }
      vim.keymap.set(
        'n',
        ']t',
        function() require('todo-comments').jump_next({ keywords = keywords }) end,
        { desc = 'Next todo comment' }
      )
      vim.keymap.set(
        'n',
        '[t',
        function() require('todo-comments').jump_prev({ keywords = keywords }) end,
        { desc = 'Prev todo comment' }
      )
    end,
    dependencies = { 'nvim-lua/plenary.nvim' },
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
          python = { 'black' },
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

  return plugins
end

return core_plugins()
