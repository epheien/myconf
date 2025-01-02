local help_winid = -1
local create_help_floatwin = function()
  if not vim.api.nvim_win_is_valid(help_winid) then
    local bufid = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = bufid }) -- 会被 :h 覆盖掉
    vim.api.nvim_set_option_value("buftype", "help", { buf = bufid })
    local width = math.min(vim.o.columns, 100)
    local col = math.floor((vim.o.columns - width) / 2)
    help_winid = vim.api.nvim_open_win(bufid, false, {
      relative = 'editor',
      row = 1,
      col = col,
      width = width,
      height = math.floor(vim.o.lines / 2),
      border = 'single',
    })
  end
  vim.api.nvim_set_current_win(help_winid)
  -- NOTE: floating window 的 winhighlight 选项会继承自调用此函数的窗口
  --       但是用下面的方法设置选项就没有问题
  vim.wo.winhighlight = '' -- 无脑清空, 因为这个窗口不允许修改配色
  vim.wo.cursorline = false
  local opt = vim.opt_local.winhighlight
  if not opt:get().NormalFloat then
    opt:append({ NormalFloat = 'Normal' })
  end
end
vim.keymap.set('c', '<CR>', function()
  if vim.fn.getcmdtype() ~= ':' then
    return '<CR>'
  end
  local line = vim.fn.getcmdline()
  if string.sub(line, 1, 1) == ' ' then -- 如果命令有前导的空格, 那么就 bypass
    return '<CR>'
  end
  local ok, parsed = pcall(vim.api.nvim_parse_cmd, line, {})
  if not ok then
    return '<CR>'
  end
  if parsed.cmd == 'help' then
    vim.schedule(function()
      create_help_floatwin()
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, true, true), 'cn', false)
    end)
    return ''
  elseif parsed.cmd == 'make' then -- 替换 make 命令为 AsyncRun make
    --vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Home>AsyncRun <End><CR>', true, true, true), 'cn', false)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-c>', true, true, true), 'cn', false)
    vim.schedule(function()
      vim.cmd('AsyncRun ' .. line) -- NOTE: 设置 g:asyncrun_open > 0 以自动打开 qf
      --vim.cmd.echo(vim.fn.string(':' .. line))
    end)
    return ''
  elseif parsed.cmd == 'terminal' then -- terminal 命令替换为 Terminal
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-c>', true, true, true), 'cn', false)
    vim.schedule(function()
      vim.cmd('T' .. string.sub(line, 2)) -- NOTE: 设置 g:asyncrun_open > 0 以自动打开 qf
    end)
    return ''
  end
  return '<CR>'
end, {silent = true, expr = true})
vim.keymap.set('n', '<F1>', function()
  create_help_floatwin()
  vim.cmd('help')
end)
vim.keymap.set('i', "<F1>", "<Nop>")
