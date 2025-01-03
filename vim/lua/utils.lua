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

local function handle_cond(spec)
  local cmd = require('pckr.loader.cmd')
  local keys = require('pckr.loader.keys') -- function(mode, key, rhs?, opts?)
  local event = require('pckr.loader.event')

  -- pckr 风格的 spec, 不处理
  if type(spec.cond) == 'string' or vim.islist(spec.cond) then
    return
  end

  local cond = {}

  -- lazy 风格的 spec 的话, 直接忽略 cond
  if spec.cmd then
    for _, c in ipairs(M.ensure_list(spec.cmd)) do
      table.insert(cond, cmd(c))
    end
    spec.cmd = nil
  end

  if spec.event then
    for _, e in ipairs(M.ensure_list(spec.event)) do
      if e ~= 'VeryLazy' then
        table.insert(cond, event(unpack(M.ensure_list(e))))
      end
    end
    spec.event = nil
  end

  if spec.keys then
    for _, k in ipairs(M.ensure_list(spec.keys)) do
      if type(k) == 'string' then
        -- { 'key1', 'key2' }
        table.insert(cond, keys('n', k))
      else
        -- { { 'key1', mode = { 'n', 'x' } }, { 'key1', mode = 'i' } }
        table.insert(cond, keys(k.mode or 'n', k[1], k[2]))
      end
    end
    spec.keys = nil
  end

  if spec.ft then
    for _, ft in ipairs(M.ensure_list(spec.ft)) do
      table.insert(cond, event('FileType', ft))
    end
    spec.ft = nil
  end

  if #cond > 0 then
    --print(spec[1], vim.inspect(cond))
    spec.cond = cond
  end
end

local function handle_opts(spec)
  if spec.config or not spec.opts then
    return
  end
  local func = function(opts)
    return function()
      -- abc-xyz.nvim, abc-xyz, abc_xyz
      local names = { vim.fn.fnamemodify(spec[1], ':t'), vim.fn.fnamemodify(spec[1], ':t:r') }
      table.insert(names, vim.fn.substitute(names[2], '-', '_', 'g'))
      for _, name in ipairs(names) do
        local ok, mod = pcall(require, name)
        if ok then
          mod.setup(opts)
          return
        end
      end
      assert(false, 'Failed to require module of plugin ' .. spec[1])
    end
  end
  spec.config = func(spec.opts)
  spec.opts = nil
end

local function setup_pckr()
  local ok, pckr = pcall(require, 'pckr')
  if not ok then
    print('ignore lua plugin: pckr')
    return
  end

  pckr.setup({
    package_root = vim.fn.stdpath('config'), ---@diagnostic disable-line
    pack_dir = vim.fn.stdpath('config'), -- 新版本用的配置名, 最终目录: pack/pckr/opt
    autoinstall = false,
  })
  return true
end

function M.handle_specs(specs)
  if vim.g.package_manager ~= 'lazy' then
    for _, spec in ipairs(specs) do
      if type(spec) == 'string' then
        goto continue
      end
      spec.requires = spec.dependencies
      spec.dependencies = nil

      handle_cond(spec)
      handle_opts(spec)

      ::continue::
    end
  end
  return specs
end

---添加插件的抽象接口, 当前使用 pckr, 以后可能会兼容 lazy.nvim
---@param specs table[]
function M.add_plugins(specs)
  M.handle_specs(specs)
  setup_pckr()
  -- NOTE: pckr.add() 的参数必须是 {{}} 的嵌套列表格式, 否则会出现奇怪的问题
  -- NOTE: 每次调用 pckr.add() 的时候都可能导致加载其他文件, 所以最好仅调用一次
  require('pckr').add(specs)
end

return M
