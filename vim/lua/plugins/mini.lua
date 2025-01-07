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
