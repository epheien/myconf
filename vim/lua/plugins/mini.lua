return {
  {
    'echasnovski/mini.indentscope',
    --enabled = false,
    version = '*',
    event = 'FileType',
    config = function()
      require('mini.indentscope').setup({
        symbol = '│',
        draw = {
          animation = require('mini.indentscope').gen_animation.none(),
        },
      })
    end,
  },

  {
    'echasnovski/mini.notify',
    enabled = not vim.g.enable_noice,
    event = 'VeryLazy',
    config = function()
      require('mini.notify').setup({
        lsp_progress = {
          enable = false,
        },
        content = {
          format = function(notif)
            local time = vim.fn.strftime('%H:%M:%S', math.floor(notif.ts_update))
            return string.format('[%s] %s', time, notif.msg)
          end,
        },
        --window = {
        --  config = {
        --    border = 'none',
        --  },
        --},
      })
      vim.api.nvim_set_hl(0, 'MiniNotifyNormal', { link = 'Normal' })
      vim.notify = require('mini.notify').make_notify()
      vim.api.nvim_create_user_command('MiniNotifyHistory', function()
        require('utils').create_scratch_floatwin('MiniNotify History')
        vim.opt_local.filetype = 'mininotify-history' -- 避免 mini.notify 新建缓冲区
        vim.opt_local.fillchars:append({ eob = ' ' })
        vim.opt_local.cursorline = true
        vim.keymap.set('n', 'q', '<C-w>q')
        require('mini.notify').show_history()
      end, { desc = 'mini.notify history' })
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
