local M = {}

-- 获取当前时区的偏移, GMT+8 即 28800
---@return integer
function M.timezone_offset()
  local now = os.time()
  return os.difftime(now, os.time(os.date('!*t', now))) ---@diagnostic disable-line
end

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

---@param tbl table
---@param sort_col? integer
---@param descending? boolean
function M.sort_table(tbl, sort_col, descending)
  if not sort_col then
    return
  end
  if not (sort_col > 0) or sort_col > #tbl.cols then
    return
  end
  -- NOTE: 如果类型之间无法比较的话, 就会报错! 尽量确保同一列为同一种类型
  table.sort(tbl.rows, function(a, b)
    local aa = a[sort_col]
    local bb = b[sort_col]
    if descending then
      return aa > bb
    else
      return aa < bb
    end
  end)
end

---渲染 Python 的 texttable 字典结构
---@param data table The table to render.
-- @param data.title string The title of the table.
-- @param data.cols string[] The headers of the table.
-- @param data.rows string[][] The rows of the table.
-- @param data.aligns string[] 'c' or 'l' or 'r'
---@param sort_col? integer > 0
---@param descending? boolean
-- @return string[]
function M.render_table(data, ascii, sort_col, descending)
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

  local sort_error = not pcall(M.sort_table, data, sort_col, descending)

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
  line = ascii and '+' or '╭'
  for i = 1, #cols do
    line = line .. string.rep(ascii and '-' or '─', colWidths[i] + 2)
    if i == #cols then
      line = line .. (ascii and '+' or '╮')
    else
      line = line .. (ascii and '+' or '┬')
    end
  end
  table.insert(lines, line)

  -- headers, 居中偏左对齐
  line = ascii and '| ' or '│ '
  for i = 1, #cols do
    local width = display_width(cols[i])
    local span = colWidths[i] - width
    local left = math.floor(span / 2)
    local right = math.floor(span / 2)
    if span % 2 ~= 0 then
      right = right + 1
    end
    line = line .. string.rep(' ', left) .. cols[i] .. string.rep(' ', right)
    local glyph = ' '
    if sort_col == i then
      glyph = sort_error and '?' or (descending and '↓' or '↑')
    end
    if i == #cols then
      line = line .. glyph .. (ascii and '|' or '│')
    else
      line = line .. glyph .. (ascii and '| ' or '│ ')
    end
  end
  table.insert(lines, line)

  line = ascii and '+' or '├'
  for i = 1, #cols do
    line = line .. string.rep(ascii and '=' or '─', colWidths[i] + 2)
    if i == #cols then
      line = line .. (ascii and '+' or '┤')
    else
      line = line .. (ascii and '+' or '┼')
    end
  end
  table.insert(lines, line)

  -- 生成数据行, 右对齐
  for _, row in ipairs(rows) do
    line = ascii and '| ' or '│ '
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
        line = line .. (ascii and ' |' or ' │')
      else
        line = line .. (ascii and ' | ' or ' │ ')
      end
    end
    table.insert(lines, line)
  end

  -- 生成表格底部
  line = ascii and '+' or '╰'
  for i = 1, #cols do
    line = line .. string.rep(ascii and '-' or '─', colWidths[i] + 2)
    if i == #cols then
      line = line .. (ascii and '+' or '╯')
    else
      line = line .. (ascii and '+' or '┴')
    end
  end
  table.insert(lines, line)

  --return table.concat(lines)
  return lines
end

---生成常用的时间戳, 时区固定为 GMT+8 (未实现)
---@param ts string|integer
---@return table
function M.make_tsdt(ts)
  -- ts 为 '2020-01-01 00:00:00' 或 1577808000 的形式
  -- return (1577808000, '2020-01-01 00:00:00') # 固定为 GMT+8 时区
  local timefmt = '%Y-%m-%d %H:%M:%S'
  local dt
  local local_offset = M.timezone_offset()
  ts = ts or os.time()

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
    ts = ts - local_offset + 28800
  else
    -- 我们用秒数偏移来处理时区即可 28800 (GMT+8)
    dt = os.date(timefmt, ts - local_offset + 28800)
  end

  return { ts, dt }
end

---render status file
--- opts = { views = { ['盘口状态'] = { sort_col = 2, descending = false } } }
---@param fname string
---@param opts table
---@return string[]
function M.render_status(fname, opts)
  opts = opts or {}
  local filters = opts.filters or {}
  local lines = {}
  table.insert(lines, '当前时间: ' .. M.make_tsdt(os.time())[2])

  for line in io.lines(fname) do
    if string.sub(line, 1, 1) == '{' then
      local tbl = vim.json.decode(line)
      if not vim.tbl_contains(filters, tbl.title) then
        local o = opts.views and (opts.views[tbl.title] or {}) or {}
        table.insert(
          lines,
          table.concat(M.render_table(tbl, o.ascii, o.sort_col, o.descending), '\n')
        )
      end
    else
      table.insert(lines, line)
    end
  end

  return lines
end

function M.status_tables_sort(title, sort_col, descending)
  local ok, opts = pcall(vim.api.nvim_buf_get_var, 0, 'status_tables_opts')
  opts = ok and opts or {}
  opts = vim.tbl_deep_extend('force', opts, {
    views = {
      [title] = {
        sort_col = sort_col,
        descending = descending,
      },
    },
  })
  vim.api.nvim_buf_set_var(0, 'status_tables_opts', opts)
end

function M.toggle_sort_on_header()
  local pos = vim.api.nvim_win_get_cursor(0)
  -- NOTE; pos[2] 和 col('.') 不一致的
  local hl = vim.fn.synIDattr(vim.fn.synID(pos[1], pos[2] + 1, 1), 'name')
  if hl ~= 'StatusTableHeader' and hl ~= 'StatusTableSortGlyph' then
    return
  end
  local prev_line = vim.fn.getline(pos[1] - 2)
  local title = prev_line:gsub('===== ', ''):gsub(' =====', '')
  local opts = vim.b.status_tables_opts or {}
  local view = opts.views and opts.views[title] or {}
  local sort_col = require('status-table').get_table_col()
  local descending
  if sort_col == view.sort_col then
    -- 正序 => 逆序 => 无序
    if view.descending == true then
      sort_col = 0
    elseif view.descending == nil then
      descending = false
    else
      descending = true
    end
  else
    descending = false
  end
  M.status_tables_sort(title, sort_col, descending)
  local charpos = vim.fn.getcursorcharpos()
  M.buffer_render_status(vim.api.nvim_get_current_buf(), opts.fname)
  -- NOTE: 由于引入了 unicode 字符, 所以需要用字符索引而不是字节索引复位光标位置
  vim.fn.setcursorcharpos(charpos[2], charpos[3], charpos[4])
end

function M.buffer_render_status(buf, fname, filters)
  -- NOTE: lines 元素可能包含有换行, 例如表格行
  local opts = {
    filters = filters,
  }
  local ok, bopts = pcall(vim.api.nvim_buf_get_var, buf, 'status_tables_opts')
  opts = vim.tbl_deep_extend('force', opts, ok and bopts or {})
  local lines = require('mylib.texttable').render_status(fname, opts)
  local content = table.concat(lines, '\n')
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(content, '\n'))
end

return M
