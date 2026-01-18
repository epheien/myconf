return {
  --'s1n7ax/nvim-window-picker',
  'epheien/nvim-window-picker',
  keys = [[\w]],
  config = function()
    require('window-picker').setup({
      hint = 'floating-big-letter',
      filter_rules = {
        include_current_win = true,
        bo = {
          filetype = { 'scrollview', 'scrollview_sign' },
          buftype = {},
        },
      },
      show_prompt = false,
      picker_config = {
        floating_big_letter = {
          position = 'top-left',
        },
      },
    })
    local function pick_window()
      local win = require('window-picker').pick_window()
      if win then
        vim.api.nvim_set_current_win(win)
      end
    end
    vim.keymap.set('n', [[\w]], pick_window, { desc = 'window-picker' })
  end,
}
