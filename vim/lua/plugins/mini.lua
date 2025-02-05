return {
  {
    'epheien/mini.indentscope',
    --enabled = false,
    version = '*',
    event = 'FileType',
    config = function()
      vim.g.miniindentscope_disable = true
      require('mini.indentscope').setup({
        symbol = '│',
        draw = {
          animation = require('mini.indentscope').gen_animation.none(),
        },
      })
    end,
  },

  {
    'epheien/mini.notify',
    event = 'VeryLazy',
    config = function()
      local MiniNotify = require('mini.notify')
      MiniNotify.setup({
        lsp_progress = {
          enable = false,
        },
        content = {
          format = function(notif)
            local time = vim.fn.strftime('%H:%M:%S', math.floor(notif.ts_update))
            return string.format('[%s] %s', time, notif.msg)
          end,
          sort = function(notif_arr)
            table.sort(notif_arr, function(a, b) return a.ts_update > b.ts_update end)
            return notif_arr
          end,
        },
        --window = {
        --  config = {
        --    border = 'none',
        --  },
        --},
      })
      vim.api.nvim_set_hl(0, 'MiniNotifyNormal', { link = 'Normal' })
      vim.notify = MiniNotify.make_notify()
      vim.api.nvim_create_user_command('MiniNotifyHistory', function()
        require('utils').create_scratch_floatwin('MiniNotify History')
        vim.opt_local.filetype = 'mininotify-history' -- 避免 mini.notify 新建缓冲区
        vim.opt_local.fillchars:append({ eob = ' ' })
        vim.opt_local.cursorline = true
        vim.keymap.set('n', 'q', '<C-w>q', { buffer = true })
        vim.keymap.set('n', 'R', '<Cmd>MiniNotifyHistory<CR>', { buffer = true })
        MiniNotify.show_history()
      end, { desc = 'show mini.notify history' })
      vim.api.nvim_create_user_command(
        'MiniNotifyClear',
        function() MiniNotify.setup(MiniNotify.config) end,
        { desc = 'clear mini.notify history' }
      )
    end,
  },

  {
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
  },

  --{
  --  'echasnovski/mini.cursorword',
  --  event = 'VeryLazy',
  --  opts = {
  --    delay = 200, -- ms
  --  },
  --},
}
