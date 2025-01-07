local vimrc_group = vim.api.nvim_create_augroup('vimrc', {})

-- smartim by hammerspoon
if vim.fn.has('mac') == 1 then
  vim.api.nvim_create_augroup('smartim', {})
  vim.api.nvim_create_autocmd({ 'VimEnter', 'VimLeavePre', 'InsertLeave', 'FocusGained' }, {
    callback = function() vim.system({ 'open', '-g', 'hammerspoon://toEnIM' }) end,
  })
end

-- rfc 文件格式支持
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  pattern = '*.txt',
  callback = function()
    if vim.regex([[rfc\d\+\.txt]]):match_str(vim.fn.expand('%:t') or '') then
      vim.bo.filetype = 'rfc'
    end
  end,
})

if vim.env.SSH_TTY then
  vim.api.nvim_create_autocmd('InsertLeave', {
    callback = function() vim.cmd.OSCYank('toEnIM()') end,
  })
end

-- from vimrc sample by Bram
-- When editing a file, always jump to the last known cursor position.
-- Don't do it when the position is invalid or when inside an event handler
-- (happens when dropping a file on gvim).
-- Also don't do it when the mark is in the first line, that is the default
-- position when opening a file.
--autocmd vimrc BufReadPost *
--    \ if line("'\"") > 1 && line("'\"") <= line("$") |
--    \     exe "normal! g`\"" |
--    \ endif
vim.api.nvim_create_autocmd('BufReadPost', {
  group = vimrc_group,
  callback = function()
    local lnum = vim.fn.line([['"]])
    if lnum > 1 and lnum <= vim.api.nvim_buf_line_count(0) then
      vim.cmd.normal({ args = { [[g`"]] }, bang = true })
    end
  end,
})

vim.api.nvim_create_autocmd('TermOpen', {
  group = vimrc_group,
  callback = function(event)
    if vim.bo.buftype ~= 'terminal' then
      return
    end
    -- 判断 snacks_dashboard 是否完成了显示
    if vim.fn.exists(':Capture') ~= 2 then
      return
    end
    vim.opt_local.list = false
    vim.opt_local.number = false
    vim.opt_local.cursorline = true
    vim.api.nvim_create_autocmd('WinEnter', {
      buffer = event.buf,
      callback = function()
        if vim.api.nvim_win_get_cursor(0)[1] == vim.api.nvim_buf_line_count(0) then
          vim.cmd.startinsert()
        end
      end,
    })
    vim.cmd.startinsert()
  end,
})

vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  group = vimrc_group,
  callback = function() vim.o.helplang = '' end,
})

-- 隐藏混乱的文件格式中的 ^M 字符
vim.api.nvim_create_autocmd('BufReadPost', {
  nested = true,
  callback = function() vim.call('myrc#FixDosFmt') end,
})

-- • Enabled treesitter highlighting for:
--   • Treesitter query files
--   • Vim help files
--   • Lua files
-- 额外的默认使用 treesitter 的文件类型
-- 事件顺序: BufReadPre => FileType => BufReadPost
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'c', 'vim', 'markdown' },
  callback = function()
    if vim.bo.filetype == 'markdown' then
      -- 非 floating window 用 treesiter 高亮, 否则就用 syntax 高亮
      if vim.api.nvim_win_get_config(0).relative == '' then
        vim.treesitter.start()
      end
    else
      vim.treesitter.start()
    end
  end,
})

vim.api.nvim_create_autocmd('BufWinEnter', {
  pattern = '*',
  callback = function()
    if vim.bo.filetype == 'help' and vim.api.nvim_win_get_config(0).relative ~= '' then
      local opt = vim.opt_local.winhighlight
      if not opt:get().NormalFloat then
        opt:append({ NormalFloat = 'Normal' })
      end
    end
  end,
})

-- 替换 spellfile.vim 标准插件的实现
vim.api.nvim_create_autocmd('SpellFileMissing', {
  callback = function(args) vim.call('spellfile#LoadFile', args.match) end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = vimrc_group,
  callback = function()
    vim.g.indentline_char = '│'
    require('config/indent-line').indentchar_update(true)
  end,
})

vim.api.nvim_create_autocmd({ 'OptionSet' }, {
  pattern = { 'shiftwidth', 'expandtab', 'tabstop' },
  group = vimrc_group,
  callback = function()
    require('config/indent-line').indentchar_update(vim.v.option_type == 'local')
  end,
})
