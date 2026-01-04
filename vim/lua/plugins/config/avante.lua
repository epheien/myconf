local M = {}

function M.avante_input_statusline()
  local sidebar = require('avante').get()
  local fun = function()
    if not sidebar:is_open() then
      return -1
    end
    return sidebar:get_tokens_usage()
  end
  local ok, tokens = pcall(fun)
  if not ok or tokens < 0 then
    return ''
  end
  local api = vim.api
  local content = ' Tokens: ' .. math.floor(tokens / 1000) .. ',' .. (tokens % 1000) .. ' '
  local padding = math.floor(
    (api.nvim_win_get_width(sidebar.containers.input.winid) - api.nvim_strwidth(content)) / 2
  )
  local padding_text = string.rep('─', padding)
  return padding_text .. '%#AvanteThirdTitle#' .. content .. '%#StatusLine#'
end

return M
