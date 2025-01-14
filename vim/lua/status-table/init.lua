local M = {}

-- 索引从 1 (1-based) 开始
function M.get_table_col()
  local line = vim.api.nvim_get_current_line()
  local orig_pos = vim.api.nvim_win_get_cursor(0)
  -- 首列不匹配分隔符或者光标停在 onemore 的末尾的时候, 忽略
  if not vim.regex([=[^[|│]]=]):match_str(line) or #line == orig_pos[2] then
    return 0
  end
  local ei = vim.o.eventignore
  vim.o.eventignore = 'all'
  local pos = orig_pos
  local count = 0
  while true do
    pos = vim.fn.searchpos([=[[|│]]=], 'b', orig_pos[1])
    if pos[1] == 0 then
      break
    end
    count = count + 1
  end
  vim.api.nvim_win_set_cursor(0, orig_pos)
  vim.o.eventignore = ei
  return count
end

return M
