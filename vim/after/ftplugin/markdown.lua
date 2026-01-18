-- 浮窗的 markdown 文件类型的窗口支持 q 退出
if vim.fn.empty(vim.api.nvim_win_get_config(0).relative) ~= 1 then
  vim.keymap.set('n', 'q', '<C-w>q', { buffer = true })
end
