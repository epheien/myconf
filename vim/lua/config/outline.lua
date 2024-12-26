local outline = require('outline')

local opts = {
  view = {
    filter = function(buf)
      local ft = vim.bo[buf].filetype
      if ft == 'qf' then return false end
      return vim.bo[buf].buflisted or ft == 'help'
    end,
  },
  providers = {
    priority = { 'lsp', 'coc', 'markdown', 'norg', 'man', 'treesitter', 'ctags' },
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
      Fragment = { icon = '●' }, -- ''
      Null = { icon = '∅' },
    },
    filter = {
      -- lua 总显示一些 if 语句很烦, 以下 filter 列表取自 aerial.nvim
      lua = {
        "Class",
        "Constructor",
        "Enum",
        "Function",
        "Interface",
        "Module",
        "Method",
        "Struct",
      },
    },
  },
}

outline.setup(opts)
