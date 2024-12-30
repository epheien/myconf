return {
  --'s1n7ax/nvim-window-picker',
  'epheien/nvim-window-picker',
  keys = [[\w]],
  config = function()
    require 'window-picker'.setup({
      hint = 'floating-big-letter',
      filter_rules = {
        include_current_win = true,
        bo = {
          filetype = { 'scrollview', 'notify' },
          buftype = {},
        },
      },
      show_prompt = false,
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
