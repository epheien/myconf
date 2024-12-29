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

-- <CR> 来重复上一条命令，10秒内连续 <CR> 的话，无需确认
vim.keymap.set('n', '<CR>', function() vim.call('myrc#MyEnter') end, { silent = true })

vim.keymap.set('i', '<Tab>', function() vim.call('myrc#SuperTab') end, { silent = true })
vim.keymap.set('i', '<S-Tab>', function() vim.call('myrc#ShiftTab') end, { silent = true })
