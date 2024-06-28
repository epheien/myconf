local lspconfig = require('lspconfig')
lspconfig.pyright.setup({})
lspconfig.lua_ls.setup({})
lspconfig.clangd.setup({
  cmd = {
    '/Users/eph/.local/share/nvim/mason/bin/clangd',
    '--header-insertion=never', -- NOTE: 添加这个选项后, '•' 前缀变成了 ' ', 需要自己过滤掉
    --'--header-insertion-decorators',
  },
})
vim.diagnostic.config({signs = false})
vim.diagnostic.config({underline = false})
-- Hide all semantic highlights
for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
  vim.api.nvim_set_hl(0, group, {})
end
