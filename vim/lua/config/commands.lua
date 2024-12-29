vim.api.nvim_create_user_command('CursorBlinkEnable', function()
  vim.o.guicursor =
  'n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175'
end, {})
vim.api.nvim_create_user_command('CursorBlinkDisable', function()
  vim.o.guicursor =
  'n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175'
end, {})
vim.api.nvim_create_user_command('LogSetup', function() vim.call('myrc#LogSetup') end, { nargs = 0 })

vim.api.nvim_create_user_command('Title', function(args)
  vim.o.title = true
  vim.o.titlestring = args.args
end, { nargs = '+' })
