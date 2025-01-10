local M = {}

---get display width
---@param str string
---@return integer
local function display_width(str)
  if vim then
    return vim.fn.strdisplaywidth(str)
  else
    return #str
  end
end

---渲染 Python 的 texttable 字典结构
---@param data table The table to render.
-- @param data.title string The title of the table.
-- @param data.cols string[] The headers of the table.
-- @param data.rows string[][] The rows of the table.
-- @param data.aligns string[] 'c' or 'l' or 'r'
-- @return string[]
function M.render_table(data)
  local title = data.title
  local cols = data.cols
  local rows = data.rows
  local aligns = data.aligns
  if not aligns then
    aligns = { 'l' } -- 默认第一个左对齐, 后面的全部向右对齐
    for i = 2, #cols do
      aligns[i] = 'r'
    end
  end

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
  local line

  -- 生成标题
  table.insert(lines, '===== ' .. title .. ' =====')

  -- 生成表头
  line = '+'
  for i = 1, #cols do
    line = line .. string.rep('-', colWidths[i] + 2) .. '+'
  end
  table.insert(lines, line)

  -- headers, 居中偏左对齐
  line = '| '
  for i = 1, #cols do
    local width = display_width(cols[i])
    local span = colWidths[i] - width
    local left = math.floor(span / 2)
    local right = math.floor(span / 2)
    if span % 2 ~= 0 then
      right = right + 1
    end
    line = line .. string.rep(' ', left) .. cols[i] .. string.rep(' ', right)
    if i == #cols then
      line = line .. ' |'
    else
      line = line .. ' | '
    end
  end
  table.insert(lines, line)

  line = '+'
  for i = 1, #cols do
    line = line .. string.rep('=', colWidths[i] + 2) .. '+'
  end
  table.insert(lines, line)

  -- 生成数据行, 右对齐
  for _, row in ipairs(rows) do
    line = '| '
    for i = 1, #row do
      local cellStr = type(row[i]) == 'string' and row[i] or tostring(row[i])

      local width = display_width(cellStr)
      local span = colWidths[i] - width
      local align = aligns[i] or 'c'
      local left, right
      if align == 'c' then
        left = math.floor(span / 2)
        right = math.floor(span / 2)
        if span % 2 ~= 0 then
          right = right + 1
        end
      elseif align == 'l' then
        left = 0
        right = span
      elseif align == 'r' then
        left = span
        right = 0
      end
      line = line .. string.rep(' ', left) .. cellStr .. string.rep(' ', right)

      if i == #row then
        line = line .. ' |'
      else
        line = line .. ' | '
      end
    end
    table.insert(lines, line)
  end

  -- 生成表格底部
  line = '+'
  for i = 1, #cols do
    line = line .. string.rep('-', colWidths[i] + 2) .. '+'
  end
  table.insert(lines, line)

  --return table.concat(lines)
  return lines
end

---生成常用的时间戳, 时区固定为 GMT+8 (未实现)
-- TODO: 处理时区问题
---@param ts string|integer
---@return table
function M.make_tsdt(ts)
  -- ts 为 '2020-01-01 00:00:00' 或 1577808000 的形式
  -- return (1577808000, '2020-01-01 00:00:00') # 固定为 GMT+8 时区
  local timefmt = '%Y-%m-%d %H:%M:%S'
  local dt

  if type(ts) == 'string' then
    dt = ts
    if not string.find(dt, ' ') then
      -- '2020-01-01' => '2020-01-01 00:00:00'
      dt = dt .. ' 00:00:00'
    end
    -- 支持 2020/01/01
    dt = string.gsub(dt, '/', '-')
    ts = os.time({
      year = string.sub(dt, 1, 4),
      month = string.sub(dt, 6, 7),
      day = string.sub(dt, 9, 10),
      hour = string.sub(dt, 12, 13),
      min = string.sub(dt, 15, 16),
      sec = string.sub(dt, 18, 19),
    })
  else
    -- 我们用秒数偏移来处理时区即可 28800 (GMT+8)
    --dt = os.date(timefmt, ts + 28800)
    dt = os.date(timefmt)
  end

  return { ts, dt }
end

---render status file
---@param fname string
---@param filters? string[]
---@return string[]
function M.render_status(fname, filters)
  filters = filters or {}
  local lines = {}
  table.insert(lines, '当前时间: ' .. M.make_tsdt(os.time())[2])

  for line in io.lines(fname) do
    if string.sub(line, 1, 1) == '{' then
      local tbl = vim.json.decode(line)
      if not vim.tbl_contains(filters, tbl.title) then
        table.insert(lines, table.concat(M.render_table(tbl), '\n'))
      end
    else
      table.insert(lines, line)
    end
  end

  return lines
end

return M
