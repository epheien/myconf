vim.keymap.set('n', 'j', 'gj', { silent = true })
vim.keymap.set('n', 'k', 'gk', { silent = true })

vim.keymap.set('n', '<RightRelease>', function()
  vim.cmd('call myrc#ContextPopup(1)')
end)

-- 禁用这些鼠标的点击
vim.keymap.set('n', '<RightMouse>', '<Nop>')
vim.keymap.set('n', '<3-LeftMouse>', '<Nop>')
vim.keymap.set('n', '<3-LeftMouse>', '<Nop>')
vim.keymap.set('n', '<4-LeftMouse>', '<Nop>')
vim.keymap.set('n', '<4-LeftMouse>', '<Nop>')
