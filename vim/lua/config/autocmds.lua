local vimrc_group = vim.api.nvim_create_augroup('vimrc', {})

-- smartim by hammerspoon
if vim.fn.has('mac') == 1 then
  vim.api.nvim_create_augroup('smartim', {})
  vim.api.nvim_create_autocmd({ 'VimEnter', 'VimLeavePre', 'InsertLeave', 'FocusGained' }, {
    callback = function()
      vim.system({ 'open', '-g', 'hammerspoon://toEnIM' })
    end
  })
end

-- rfc 文件格式支持
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  pattern = '*.txt',
  callback = function()
    if vim.regex([[rfc\d\+\.txt]]):match_str(vim.fn.expand('%:t')) then
      vim.bo.filetype = 'rfc'
    end
  end
})

if vim.env.SSH_TTY then
  vim.api.nvim_create_autocmd('InsertLeave', {
    callback = function()
      vim.cmd.OSCYank('toEnIM()')
    end,
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
  end
})
