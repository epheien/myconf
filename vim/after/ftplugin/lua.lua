vim.keymap.set({ 'n', 'v', 'o' }, '[[', function()
  local pos = vim.api.nvim_win_get_cursor(0)
  local buf = vim.api.nvim_get_current_buf()
  require('tree-climber').goto_parent()
  local after_pos = vim.api.nvim_win_get_cursor(0)
  if pos[1] ~= after_pos[1] or pos[2] ~= after_pos[2] then
    vim.api.nvim_buf_set_mark(buf, [[']], pos[1], pos[2], {})
  end
end, { noremap = true, silent = true, buffer = true })
