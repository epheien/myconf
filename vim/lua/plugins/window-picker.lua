return {
  's1n7ax/nvim-window-picker',
  keys = [[\w]],
  config = function()
    require 'window-picker'.setup({
      hint = 'floating-big-letter',
    })
    local function pick_window()
      local win = require('window-picker').pick_window()
      if win then
        vim.api.nvim_set_current_win(win)
      end
    end
    vim.keymap.set('n', [[\w]], pick_window)
  end,
}
