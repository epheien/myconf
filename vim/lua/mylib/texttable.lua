local M = {}

local function display_width(str)
  if vim then
    return vim.fn.strdisplaywidth(str)
  else
    return #str
  end
end

function M.render_table(data)
  local cols = data.cols
  local rows = data.rows
  local title = data.title

  local colWidths = {}

  -- 计算每列的最大宽度
  for i = 1, #cols do
    local maxWidth = display_width(cols[i])
    for _, row in ipairs(rows) do
      local cellStr = type(row[i]) == 'string' and row[i] or tostring(row[i])
      maxWidth = math.max(maxWidth, display_width(cellStr))
    end
    colWidths[i] = maxWidth
  end

  local lines = {}

  -- 生成标题
  lines[#lines + 1] = '===== ' .. title .. ' =====\n'

  -- 生成表头
  lines[#lines + 1] = '+'
  for i = 1, #cols do
    lines[#lines + 1] = string.rep('-', colWidths[i] + 2) .. '+'
  end
  lines[#lines + 1] = '\n'

  -- headers, 居中偏左对齐
  lines[#lines + 1] = '| '
  for i = 1, #cols do
    local width = display_width(cols[i])
    local span = colWidths[i] - width
    local left = math.floor(span / 2)
    local right = math.floor(span / 2)
    if span % 2 ~= 0 then
      left = left + 1
    end
    lines[#lines + 1] = string.rep(' ', left) .. cols[i] .. string.rep(' ', right)
    if i == #cols then
      lines[#lines + 1] = ' |'
    else
      lines[#lines + 1] = ' | '
    end
  end
  lines[#lines + 1] = '\n'

  lines[#lines + 1] = '+'
  for i = 1, #cols do
    lines[#lines + 1] = string.rep('=', colWidths[i] + 2) .. '+'
  end
  lines[#lines + 1] = '\n'

  -- 生成数据行, 右对齐
  for _, row in ipairs(rows) do
    lines[#lines + 1] = '| '
    for i = 1, #row do
      local cellStr = type(row[i]) == 'string' and row[i] or tostring(row[i])
      lines[#lines + 1] = string.rep(' ', colWidths[i] - display_width(cellStr)) .. cellStr
      if i == #row then
        lines[#lines + 1] = ' |'
      else
        lines[#lines + 1] = ' | '
      end
    end
    lines[#lines + 1] = '\n'
  end

  -- 生成表格底部
  lines[#lines + 1] = '+'
  for i = 1, #cols do
    lines[#lines + 1] = string.rep('-', colWidths[i] + 2) .. '+'
  end

  --return table.concat(lines)
  return lines
end

return M
