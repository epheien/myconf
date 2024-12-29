local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_deep_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

map('n', 'j', 'gj')
map('n', 'k', 'gk')

map('n', '<RightRelease>', function() vim.cmd('call myrc#ContextPopup(1)') end)

-- 禁用这些鼠标的点击
map('n', '<RightMouse>', '<Nop>')
map('n', '<3-LeftMouse>', '<Nop>')
map('n', '<3-LeftMouse>', '<Nop>')
map('n', '<4-LeftMouse>', '<Nop>')
map('n', '<4-LeftMouse>', '<Nop>')

-- <CR> 来重复上一条命令，10秒内连续 <CR> 的话，无需确认
map('n', '<CR>', function() vim.call('myrc#MyEnter') end)

map('i', '<Tab>', function() vim.call('myrc#SuperTab') end)
map('i', '<S-Tab>', function() vim.call('myrc#ShiftTab') end)

map('n', '<C-f>', function() vim.call('mydict#Search', vim.fn.expand('<cword>')) end)

map('n', '<C-f>', function() vim.call('mydict#Search', vim.fn.expand('<cword>')) end)
map('v', '<C-f>', 'y:call mydict#Search(@")<CR>')

map('n', '<C-]>', function() vim.call('myrc#Cstag') end)

map("n", "<M-h>", ":tabNext<CR>")
map("n", "<M-l>", ":tabnext<CR>")
map("n", "<M-j>", "<C-w>-")
map("n", "<M-k>", "<C-w>+")

-- Terminal mode mappings
map("t", "<M-h>", "<C-\\><C-n>:tabNext<CR>")
map("t", "<M-l>", "<C-\\><C-n>:tabnext<CR>")

-- Insert mode mappings
map("i", "<M-h>", "<C-\\><C-o>:tabNext<CR>")
map("i", "<M-l>", "<C-\\><C-o>:tabnext<CR>")
