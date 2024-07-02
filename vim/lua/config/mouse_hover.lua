local M = {}

M.get_debugger_button_tips = function(wincol)
  local button_label = {
    [3] = 'play',
    [6] = 'step into',
    [9] = 'step over',
    [12] = 'step out',
    [15] = 'step back',
    [18] = 'run last',
    [21] = 'terminate',
    [24] = 'disconnect',
  }
  if wincol >= 24 then
    return button_label[24]
  elseif wincol >= 21 then
    return button_label[21]
  elseif wincol >= 18 then
    return button_label[18]
  elseif wincol >= 15 then
    return button_label[15]
  elseif wincol >= 12 then
    return button_label[12]
  elseif wincol >= 9 then
    return button_label[9]
  elseif wincol >= 6 then
    return button_label[6]
  elseif wincol >= 3 then
    return button_label[3]
  else
    return nil
  end
end

function M.callback()
  local mouse_pos = vim.fn.getmousepos()
  if mouse_pos.winid == 0 then
    return nil
  end
  local bufname = vim.fn.bufname(vim.api.nvim_win_get_buf(mouse_pos.winid))

  -- dapui winbar 按钮提示
  if mouse_pos.winrow == 1 and vim.fn.match(bufname, [[^\[dap-repl]]) then
    local label = M.get_debugger_button_tips(mouse_pos.wincol)
    if label then
      return {string.format(' %s ', label)}
    else
      return nil
    end
  end

  return nil
end

return M
