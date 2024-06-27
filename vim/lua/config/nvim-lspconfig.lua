local lspconfig = require('lspconfig')
lspconfig.pyright.setup({})
lspconfig.lua_ls.setup({})
lspconfig.clangd.setup({
  cmd = {'clangd', '--header-insertion=never'},
})
vim.diagnostic.config({signs = false})
vim.diagnostic.config({underline = false})
-- Hide all semantic highlights
for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
  vim.api.nvim_set_hl(0, group, {})
end
