vim.keymap.set({ 'n', 'v', 'o' }, '[[', function()
  -- BUG: 用 nvim_buf_set_mark() 会有问题
  vim.fn.win_execute(vim.api.nvim_get_current_win(), "normal! m'")
  require('tree-climber').goto_parent()
end, { noremap = true, silent = true, buffer = true })
