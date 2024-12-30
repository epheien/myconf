local M = {}

local scratch_winid = -1
M.create_scratch_floatwin = function(title)
  local bufid
  title = string.format(' %s ', title) or ' More Prompt '
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
      border = 'rounded',
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
  return bufid, scratch_winid
end

function M.floatwin_run(cmd)
  local output = vim.api.nvim_exec2(cmd, { output = true }).output
  if output == '' then return end
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
  vim.g.gitgutter_override_sign_column_highlight = 1
  vim.o.background = 'dark'
  local ok = pcall(vim.cmd.colorscheme, colors_name)
  if not ok then
    print('colorscheme gruvbox failed, fallback to gruvbox-origin')
    vim.cmd.colorscheme('gruvbox-origin')
  end
end

-- 统一转为 { {...} }
-- 'abc' => { { 'abc' } }
-- { 'abc' } => { { 'abc' } }
local function norm_value(value)
  if type(value) == 'string' then
    return { { value } }
  end
  if type(value[1]) == 'string' then
    return { value }
  end
end

local function ensure_list(v)
  if not vim.islist(v) then
    return { v }
  end
  return v
end

---添加插件的抽象接口, 当前使用 pckr, 以后可能会兼容 lazy.nvim
---@param specs table[]
function M.add_plugins(specs)
  local cmd = require('pckr.loader.cmd')
  local keys = require('pckr.loader.keys') -- function(mode, key, rhs?, opts?)
  local event = require('pckr.loader.event')

  for _, spec in ipairs(specs) do
    if type(spec) == 'string' then
      goto continue
    end

    local cond = {}

    -- lazy spec 风格的话, 直接忽略 cond
    if spec.cmd then
      for _, c in ipairs(ensure_list(spec.cmd)) do
        table.insert(cond, cmd(c))
      end
    end

    if spec.event then
      for _, e in ipairs(ensure_list(spec.event)) do
        table.insert(cond, event(unpack(ensure_list(e))))
      end
    end

    if spec.keys then
      for _, k in ipairs(ensure_list(spec.keys)) do
        if type(k) == 'string' then
          -- { 'key1', 'key2' }
          table.insert(cond, keys('n', k))
        else
          -- { { 'n', 'key1' }, { 'x', 'key1' } }
          table.insert(cond, keys(unpack(k)))
        end
      end
    end

    if spec.cmd or spec.event or spec.keys then
      spec.cmd = nil
      spec.event = nil
      spec.keys = nil
      goto out
    end

    if type(spec.cond) ~= "table" or vim.islist(spec.cond) then
      goto continue
    end

    -- 确保 cond 是字典了
    -- 转换 cond
    -- {
    --   cond = {
    --     keys = { { 'n', 'p' } },
    --     cmd = { 'abc' },
    --     event = { { 'FileType', 'lua' } },
    --   }
    -- }
    if spec.cond.keys then
      for _, k in ipairs(norm_value(spec.cond.keys)) do
        table.insert(cond, keys(unpack(k)))
      end
    end
    if spec.cond.cmd then
      for _, c in ipairs(spec.cond.cmd) do
        table.insert(cond, cmd(c))
      end
    end
    if spec.cond.event then
      for _, e in ipairs(spec.cond.event) do
        table.insert(cond, event(unpack(e)))
      end
    end

    ::out::
    --print(spec[1], vim.inspect(cond))
    spec.cond = cond

    ::continue::
  end
  require('pckr').add(specs)
end

return M
