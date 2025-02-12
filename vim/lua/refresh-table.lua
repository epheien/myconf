local M = {}

-- bufnr => timer
M.timers = {}

---@param winid integer
function M.stop_refresh(winid)
  local bufnr = vim.api.nvim_win_get_buf(winid)
  local t = M.timers[bufnr]
  if t then
    t:stop()
  end
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
  vim.keymap.set('n', '<CR>', require('mylib.texttable').toggle_sort_on_header, { buffer = bufnr })
  vim.keymap.set('n', '<2-LeftMouse>', '<CR>', { buffer = bufnr, remap = true })
  vim.api.nvim_create_autocmd('BufUnload', {
    buffer = bufnr,
    callback = function() M.stop_refresh(bufnr) end,
  })

  local timer = vim.uv.new_timer() ---@diagnostic disable-line
  timer:start(0, interval, function()
    vim.schedule(function()
      local t = type(tbl) == 'function' and tbl() or tbl --[[@as string]]
      require('mylib.texttable').buffer_render_status(bufnr, t, { timestamp = true })
    end)
  end)
  M.timers[bufnr] = timer
end

return M
