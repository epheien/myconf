local M = {}

-- NOTE: Capture 命令生成的标题差异化很大, 可能会导致这个结构无限膨胀
local scratch_winids = {}
---@param title string
---@param opts? table config for nvim_open_win()
---@return integer bufid
---@return integer winid
function M.create_scratch_floatwin(title, opts)
  title = string.format(' %s ', title) or ' More Prompt '
  local scratch_winid = scratch_winids[title] or -1
  local bufid
  if not vim.api.nvim_win_is_valid(scratch_winid) then
    bufid = vim.api.nvim_create_buf(false, true)
    local bo = vim.bo[bufid]
    bo.bufhidden = 'wipe'
    bo.buftype = 'nofile'
    bo.swapfile = false
    local width = math.min(vim.o.columns, 100)
    local col = math.floor((vim.o.columns - width) / 2)
    scratch_winid = vim.api.nvim_open_win(
      bufid,
      false,
      vim.tbl_deep_extend('force', {
        relative = 'editor',
        row = math.floor((vim.o.lines - 2) / 4),
        col = col,
        width = width,
        height = math.floor(vim.o.lines / 2),
        border = 'single',
        title = title,
        title_pos = 'center',
      }, opts or {})
    )
    vim.keymap.set('n', 'q', '<C-w>q', { buffer = bufid, remap = false })
  else
    bufid = vim.api.nvim_win_get_buf(scratch_winid)
    --local config = vim.api.nvim_win_get_config(scratch_winid)
    --config.title = title
    --vim.api.nvim_win_set_config(scratch_winid, config)
  end
  vim.api.nvim_set_current_win(scratch_winid)
  vim.opt_local.number = false
  vim.opt_local.colorcolumn = {}
  local opt = vim.opt_local.winhighlight
  if not opt:get().NormalFloat then
    opt:append({ NormalFloat = 'Normal' })
  end
  scratch_winids[title] = scratch_winid
  return bufid, scratch_winid
end

function M.floatwin_run(cmd)
  local output = vim.api.nvim_exec2(cmd, { output = true }).output
  if output == '' then
    return
  end
  local bufid = M.create_scratch_floatwin(cmd)
  vim.bo[bufid].modifiable = true
  vim.api.nvim_buf_set_lines(bufid, 0, -1, false, vim.split(output, '\n'))
  vim.bo[bufid].modifiable = false
end

local only_ascii
function M.only_ascii()
  if only_ascii ~= nil then
    return only_ascii
  end
  local pat = vim.regex([=[\V\<iTerm\|\<Apple_Terminal\|\<kitty\|\<alacritty\|\<tmux\|\<ghostty]=])
  if vim.fn.has('gui_running') == 1 or pat:match_str(vim.env.TERM_PROGRAM or '') then
    only_ascii = false
  else
    only_ascii = true
  end
  return only_ascii
end

-- 颜色方案
-- https://hm66hd.csb.app/ 真彩色 => 256色 在线工具
-- 转换逻辑可在 unused/CSApprox 插件找到 (会跟在线工具有一些差别, 未深入研究)
function M.setup_colorscheme(colors_name)
  -- 这个选项能直接控制 gruvbox 的 sign 列直接使用 LineNr 列的高亮组
  vim.o.background = 'dark'
  local ok = pcall(vim.cmd.colorscheme, colors_name)
  if not ok then
    print('colorscheme gruvbox failed, fallback to gruvbox-origin')
    vim.cmd.colorscheme('gruvbox-origin')
  end
end

function M.ensure_list(v)
  if not vim.islist(v) then
    return { v }
  end
  return v
end

function M.modify_hl(name, opts)
  local o = vim.api.nvim_get_hl(0, { name = name })
  ---@diagnostic disable-next-line
  vim.api.nvim_set_hl(0, name, vim.tbl_deep_extend('force', o, opts))
end

function M.empty(v) return vim.fn.empty(v) == 1 end

function M.feedkeys(keys, mode)
  local str = vim.api.nvim_replace_termcodes(keys, true, false, true)
  vim.api.nvim_feedkeys(str, mode, false)
end

-- 固定打印日志到当前目录的 temp.txt
function M.log_to_file(...)
  local file = io.open('temp.txt', 'a')
  if file then
    for i = 1, select('#', ...) do
      local text = select(i, ...)
      if type(text) == 'string' then
        file:write(text .. ' ')
      else
        file:write(vim.inspect(text) .. ' ')
      end
    end
    file:write('\n')
    file:close()
  end
end

---@param winid? integer|nil
function M.jump_to_end(winid)
  winid = winid or 0
  local bufnr = vim.api.nvim_win_get_buf(winid)
  local lnum = vim.api.nvim_buf_line_count(bufnr)
  local last_line = vim.api.nvim_buf_get_lines(bufnr, -2, -1, true)[1]
  vim.api.nvim_win_set_cursor(winid, { lnum, #last_line })
end

M.multi_line_input_history = {}

---@param title string
---@param opts? table { submit?: booloan }
function M.multi_line_input(title, opts)
  title = title or 'Multi-line Input'
  opts = opts or {}

  local width = math.min(vim.o.columns, 40)
  local height = 10
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  local bufid, winid =
    M.create_scratch_floatwin(title, { row = row, col = col, width = width, height = height })
  vim.api.nvim_set_option_value('filetype', 'MultiLineInput', { scope = 'local', buf = bufid })
  vim.b.history_idx = #M.multi_line_input_history + 1
  vim.cmd([[syntax match Special /@\w\+/]])
  vim.cmd('startinsert')

  local buf_lines = {}

  vim.keymap.set('i', '<C-s>', function()
    local lines = vim.api.nvim_buf_get_lines(bufid, 0, -1, false)
    vim.cmd('stopinsert')
    vim.api.nvim_win_close(winid, false)
    local str = table.concat(lines, '\n')
    if str == '' then
      return
    end
    require('opencode').prompt(str, { submit = opts.submit, clear = true })
    table.insert(M.multi_line_input_history, lines)
    if #M.multi_line_input_history > 200 then
      table.remove(M.multi_line_input_history, 1)
    end
  end, { buffer = bufid, remap = false, desc = 'Submit to opencode' })

  vim.keymap.set({ 'n', 'i' }, '<C-c>', function()
    vim.cmd('stopinsert')
    vim.api.nvim_win_close(winid, false)
  end, { buffer = bufid, remap = false, desc = 'close window' })

  vim.keymap.set('i', '<C-p>', function()
    if #M.multi_line_input_history == 0 then
      return
    end
    if vim.b.history_idx == #M.multi_line_input_history + 1 then
      buf_lines = vim.api.nvim_buf_get_lines(bufid, 0, -1, false)
    end
    local lines = M.multi_line_input_history[vim.b.history_idx - 1]
    if lines then
      vim.api.nvim_buf_set_lines(bufid, 0, -1, false, lines)
      vim.b.history_idx = vim.b.history_idx - 1
      M.jump_to_end(winid)
    end
  end, { buffer = bufid, remap = false })

  vim.keymap.set('i', '<C-n>', function()
    if vim.b.history_idx == #M.multi_line_input_history + 1 then
      return
    end
    local lines
    if vim.b.history_idx == #M.multi_line_input_history then
      lines = buf_lines
    else
      lines = M.multi_line_input_history[vim.b.history_idx + 1]
    end
    vim.api.nvim_buf_set_lines(bufid, 0, -1, false, lines)
    vim.b.history_idx = vim.b.history_idx + 1
    M.jump_to_end(winid)
  end, { buffer = bufid, remap = false })
end

return M
