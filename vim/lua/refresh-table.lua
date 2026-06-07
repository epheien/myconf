local M = {}

-- bufnr => timer
M.timers = {}

---@param bufnr integer
function M.stop_refresh(bufnr)
  local t = M.timers[bufnr]
  if not t then
    return
  end
  t:stop()
  t:close()
  M.timers[bufnr] = nil
end

---@param winid integer
---@param tbl texttable.Table|function
---@param interval integer ms
function M.refresh_status_table(winid, tbl, interval)
  local bufnr = vim.api.nvim_win_get_buf(winid)
  if M.timers[bufnr] then
    vim.api.nvim_err_writeln(string.format('bufnr %d already running status table', bufnr))
    return
  end
  local bo = vim.bo[bufnr]
  local wo = vim.wo[winid]
  bo.buftype = 'nofile'
  bo.swapfile = false
  bo.bufhidden = 'wipe'
  bo.undolevels = 100
  bo.buflisted = false
  bo.filetype = 'status_table'
  wo.colorcolumn = ''
  wo.list = false
  wo.cursorline = true
  wo.wrap = false
  wo.virtualedit = 'none'
  vim.keymap.set('n', '<CR>', function()
    local t = type(tbl) == 'function' and tbl() or tbl --[[@as texttable.Table]]
    require('mylib.texttable').toggle_sort_on_header(t)
  end, { buffer = bufnr })
  vim.keymap.set('n', '<2-LeftMouse>', '<CR>', { buffer = bufnr, remap = true })
  vim.api.nvim_create_autocmd('BufUnload', {
    buffer = bufnr,
    callback = function() M.stop_refresh(bufnr) end,
  })

  local timer = vim.uv.new_timer() ---@diagnostic disable-line
  timer:start(0, interval, function()
    vim.schedule(function()
      local t = tbl --[[@as texttable.Table]]
      local opts = nil
      if type(tbl) == 'function' then
        t, opts = tbl()
      end
      require('mylib.texttable').buffer_render_status(bufnr, t, opts)
    end)
  end)
  M.timers[bufnr] = timer
end

---@param fname string
---@param interval? integer ms
---@param bufid? integer
function M.refresh_status_tables(fname, interval, bufid)
  bufid = bufid or vim.api.nvim_get_current_buf()
  if M.timers[bufid] then
    vim.notify('timer is already running', vim.log.levels.ERROR)
    return
  end
  interval = interval or 1000

  local bo = vim.bo[bufid]
  bo.buftype = 'nofile'
  bo.swapfile = false
  bo.bufhidden = 'wipe'
  bo.undolevels = 100
  bo.buflisted = false
  bo.filetype = 'status_table'

  local winid = vim.fn.bufwinid(bufid)
  if winid >= 0 then
    local wo = vim.wo[winid]
    wo.wrap = false
    wo.colorcolumn = ''
    wo.list = false
    wo.cursorline = true
  end

  vim.keymap.set(
    'n',
    '<CR>',
    function() require('mylib.texttable').toggle_sort_on_header(fname) end,
    { buffer = bufid }
  )
  vim.keymap.set('n', '<2-LeftMouse>', '<CR>', { buffer = bufid, remap = true })
  vim.api.nvim_create_autocmd('BufUnload', {
    buffer = bufid,
    callback = function() M.stop_refresh_status_tables(bufid) end,
  })

  local function tick()
    if vim.fn.bufwinid(bufid) < 0 then
      return
    end
    require('mylib.texttable').buffer_render_status(bufid, vim.fn.expand(fname))
  end

  tick()
  local timer = vim.uv.new_timer() ---@diagnostic disable-line
  timer:start(interval, interval, vim.schedule_wrap(tick)) ---@diagnostic disable-line
  M.timers[bufid] = timer
end

---@param bufnr? integer
function M.stop_refresh_status_tables(bufnr) M.stop_refresh(bufnr or vim.api.nvim_get_current_buf()) end

return M
