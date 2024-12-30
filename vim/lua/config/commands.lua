vim.api.nvim_create_user_command('CursorBlinkEnable', function()
  vim.o.guicursor =
    'n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175'
end, {})
vim.api.nvim_create_user_command('CursorBlinkDisable', function()
  vim.o.guicursor =
    'n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175'
end, {})
vim.api.nvim_create_user_command('LogSetup', function()
  vim.call('myrc#LogSetup')
end, { nargs = 0 })

vim.api.nvim_create_user_command('Title', function(args)
  vim.o.title = true
  vim.o.titlestring = args.args
end, { nargs = '+' })

vim.api.nvim_create_user_command('Dict', function(args)
  vim.call('mydict#Search', args.args)
end, { nargs = '+' })

vim.api.nvim_create_user_command('EnableOSCYank', function()
  vim.call('myrc#enable_oscyank')
end, { nargs = 0 })

vim.api.nvim_create_user_command('DisableOSCYank', function()
  vim.call('myrc#disable_oscyank')
end, { nargs = 0 })

vim.api.nvim_create_user_command('Terminal', function(args)
  vim.cmd.split()
  vim.cmd.terminal(args.args == '' and {} or args.args)
end, { nargs = '*' })

-- 清理后置的多余的空白
vim.api.nvim_create_user_command('CleanSpaces', function()
  vim.cmd([[silent! %s/\s\+$//g | noh | normal! ``]])
end, { nargs = 0 })

vim.api.nvim_create_user_command('CsFind', function(args)
  vim.call('myrc#CscopeFind', args.args)
end, { nargs = '+', complete = 'file' })

vim.api.nvim_create_user_command('Man', function(args)
  vim.call('myrc#Man', args.mods, args.args)
end, {})

vim.api.nvim_create_user_command('RefreshStatusTables', function(args)
  vim.call('myrc#RefreshStatusTables', unpack(args.fargs))
end, { nargs = '+', complete = 'file' })

vim.api.nvim_create_user_command('Rg', function(args)
  vim.call('myrc#rg', args.args)
end, { nargs = '+', complete = 'file' })

vim.api.nvim_create_user_command('Capture', function(opt)
  require('utils').floatwin_run(opt.args)
end, {
  nargs = '+',
  complete = function(arg_lead, cmd_line, cursor_pos) ---@diagnostic disable-line
    local line = vim.fn.substitute(cmd_line, [=[^\s*\w\+\s\+]=], '', '')
    return vim.fn.getcompletion(line, 'cmdline')
  end,
})
