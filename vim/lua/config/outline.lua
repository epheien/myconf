local outline = require('outline')

local opts = {
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
  },
}

outline.setup(opts)
