vim.api.nvim_create_user_command(
  'CursorBlinkEnable',
  function()
    vim.o.guicursor =
      'n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175'
  end,
  {}
)
vim.api.nvim_create_user_command(
  'CursorBlinkDisable',
  function()
    vim.o.guicursor =
      'n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175'
  end,
  {}
)
vim.api.nvim_create_user_command(
  'LogSetup',
  function() vim.call('myrc#LogSetup') end,
  { nargs = 0 }
)

vim.api.nvim_create_user_command('Title', function(args)
  vim.o.title = true
  vim.o.titlestring = args.args
  if vim.env.TMUX then
    vim.system({ 'tmux', 'rename-window', '--', vim.o.titlestring })
  end
end, { nargs = '+' })

vim.api.nvim_create_user_command('TabTitle', function(args)
  vim.t.title = args.args
  vim.cmd.redrawtabline()
end, { nargs = '+' })

vim.api.nvim_create_user_command(
  'Dict',
  function(args) vim.call('mydict#Search', args.args) end,
  { nargs = '+' }
)

vim.api.nvim_create_user_command(
  'EnableOSCYank',
  function() vim.call('myrc#enable_oscyank') end,
  { nargs = 0 }
)

vim.api.nvim_create_user_command(
  'DisableOSCYank',
  function() vim.call('myrc#disable_oscyank') end,
  { nargs = 0 }
)

vim.api.nvim_create_user_command('Terminal', function(args)
  vim.cmd.split()
  vim.cmd.terminal(args.args == '' and {} or args.args)
  vim.b.miniindentscope_disable = true -- disable mini.indentscope
end, { nargs = '*' })

-- 清理后置的多余的空白
vim.api.nvim_create_user_command(
  'CleanSpaces',
  function() vim.cmd([[silent! %s/\s\+$//g | noh | normal! ``]]) end,
  { nargs = 0 }
)

vim.api.nvim_create_user_command(
  'FixNullChars',
  function() vim.cmd([=[silent! %s/\%x00/\r/g]=]) end,
  { nargs = 0 }
)

vim.api.nvim_create_user_command(
  'CsFind',
  function(args) vim.call('myrc#CscopeFind', args.args) end,
  { nargs = '+', complete = 'file' }
)

vim.api.nvim_create_user_command(
  'RefreshStatusTables',
  function(args) vim.call('myrc#RefreshStatusTables', unpack(args.fargs)) end,
  { nargs = '+', complete = 'file' }
)

vim.api.nvim_create_user_command(
  'StopRefreshStatusTables',
  function() vim.call('myrc#StopRefreshStatusTables') end,
  { nargs = 0 }
)

vim.api.nvim_create_user_command(
  'Rg',
  function(args) vim.call('myrc#rg', args.args) end,
  { nargs = '+', complete = 'file' }
)

vim.api.nvim_create_user_command(
  'Capture',
  function(opt) require('utils').floatwin_run(opt.args) end,
  {
    nargs = '+',
    complete = function(arg_lead, cmd_line, cursor_pos) ---@diagnostic disable-line
      local line = vim.fn.substitute(cmd_line, [=[^\s*\w\+\s\+]=], '', '')
      return vim.fn.getcompletion(line, 'cmdline')
    end,
  }
)

vim.api.nvim_create_user_command('Base46Compile', function()
  -- 主题以及其他选项在 nvconfig 里面, nvconfig 会从 chadrc 里面读取覆盖的选项
  -- 主题分别从 base46.themes 和 themes 目录里寻找
  require('base46').compile(
    vim.fs.joinpath(
      vim.fn.stdpath('config') --[[@as string]],
      'plugpack/onedark-nvchad/lua/onedark-nvchad/soft'
    )
  )
end, {})

vim.api.nvim_create_user_command('Opencode', function(opts)
  local arg = opts.args

  if vim.g.loaded_opencode_plugin or vim.g.loaded_opencode_nvim then
    vim.notify('Opencode 已经加载，无法切换', vim.log.levels.WARN)
    return
  end

  if vim.fn.empty(arg) == 1 or arg == 'plugin' then
    require('lazy').load({ plugins = { 'opencode-plugin' } })
    vim.notify('Opencode plugin 已加载')
    vim.cmd('Opencode toggle')
  elseif arg == 'frontend' then
    require('lazy').load({ plugins = { 'opencode.nvim' } })
    vim.notify('Opencode frontend 已加载')
    vim.cmd('Opencode toggle')
  else
    vim.notify('用法: Opencode plugin 或 Opencode frontend', vim.log.levels.ERROR)
  end
end, {
  nargs = '*',
  complete = function()
    if vim.g.loaded_opencode_plugin or vim.g.loaded_opencode_nvim then
      return {}
    end
    return { 'plugin', 'frontend' }
  end,
})
