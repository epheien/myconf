local outline = require('outline')

local opts = {
  providers = {
    priority = { 'lsp', 'ctags', 'coc', 'markdown', 'norg' },
    ctags = {
      filetypes = {
        ['c++'] = {
          kinds = {
          },
        },
        markdown = {
          scope_sep = '""',
        },
      }
    },
  },
  outline_window = {
    width = 30,
    relative_width = false,
    focus_on_open = false,
  },
  keymaps = {
    close = { 'q' },
    goto_location = { '<CR>', '<2-LeftMouse>' },
    fold_all = 'zM',
    unfold_all = 'zR',
    down_and_jump = {},
    up_and_jump = {},
    restore_location = {},
  },
  symbol_folding = {
    autofold_depth = 2;
  },
  outline_items = {
    auto_update_events = {
      follow = { 'CursorHold' },
    },
  },
  symbols = {
    icons = {
      TypeAlias = { icon = '', hl = 'Type' },
    }
  },
}

outline.setup(opts)
