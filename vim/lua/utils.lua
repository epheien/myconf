local M = {}

-- NOTE: Capture 命令生成的标题差异化很大, 可能会导致这个结构无限膨胀
local scratch_winids = {}
M.create_scratch_floatwin = function(title)
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
    scratch_winid = vim.api.nvim_open_win(bufid, false, {
      relative = 'editor',
      row = math.floor((vim.o.lines - 2) / 4),
      col = col,
      width = width,
      height = math.floor(vim.o.lines / 2),
      border = 'single',
      title = title,
      title_pos = 'center',
    })
    vim.keymap.set('n', 'q', '<C-w>q', { buffer = bufid, remap = false })
  else
    bufid = vim.api.nvim_win_get_buf(scratch_winid)
    local config = vim.api.nvim_win_get_config(scratch_winid)
    config.title = title
    vim.api.nvim_win_set_config(scratch_winid, config)
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
  local pat = vim.regex([=[\V\<iTerm\|\<Apple_Terminal\|\<kitty\|\<alacritty\|\<tmux]=])
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

return M
