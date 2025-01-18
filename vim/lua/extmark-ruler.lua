local M = {}

local ns_id = vim.api.nvim_create_namespace('float-ruler')
local extmark_id = nil

-- stylua: ignore
local mode_table = {
  ['v']    = 'VISUAL',
  ['vs']   = 'VISUAL',
  ['V']    = 'V-LINE',
  ['Vs']   = 'V-LINE',
  ['\22']  = 'V-BLOCK',
  ['\22s'] = 'V-BLOCK',
  ['s']    = 'SELECT',
  ['S']    = 'S-LINE',
  ['\19']  = 'S-BLOCK',
}

local function clear_extmark(buf, lnum)
  if extmark_id then
    vim.api.nvim_buf_clear_namespace(buf, ns_id, lnum - 1, lnum)
    extmark_id = nil
  end
end

---@param win? integer
local function refresh_ruler_extmark(win)
  win = win or vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(win)
  local pos = vim.api.nvim_win_get_cursor(win)
  local mode = vim.api.nvim_get_mode().mode
  local m = (mode_table[mode] or ''):sub(1, 1)
  if not (m == 'V' or m == 'S') then -- 仅支持在可视/选择模式显示
    clear_extmark(buf, pos[1])
    return
  end
  local str = vim.api.nvim_eval_statusline('%S', { winid = win }).str
  if (m == 'V' or m == 'S') and str == '' then -- 可视/选择模式的空字符串不刷新
    return
  end
  if str == '' then
    clear_extmark(buf, pos[1])
    return
  end
  extmark_id = vim.api.nvim_buf_set_extmark(buf, ns_id, pos[1] - 1, 0, {
    id = extmark_id,
    virt_text = { { str .. ' ', 'Special' } },
    virt_text_pos = 'right_align',
  })
end

function M.setup()
  refresh_ruler_extmark()
  vim.api.nvim_create_autocmd({ 'ModeChanged', 'CursorMoved' }, {
    callback = function() refresh_ruler_extmark() end,
  })
end

return M
