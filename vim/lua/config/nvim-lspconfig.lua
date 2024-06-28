local lspconfig = require('lspconfig')

-- lsp server 对应的扩展名, 不存在就不会启动 lsp
-- TODO: 可以切换为 FileType 驱动, 需要在事件处理回调再次触发一次事件
local server_exts = {
  clangd = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
  lua_ls = {'lua'},
  pyright = {'py'},
  gopls = {'go'},
}

local already_setup = {}
local ext_to_server = {}

-- 扩展名映射到 lsp 服务器名称
local function ext_to_lsp_server(ext)
  if #ext_to_server == 0 then
    for server, exts in pairs(server_exts) do
      for _, e in ipairs(exts) do
        ext_to_server[e] = server
      end
    end
  end
  return ext_to_server[ext]
end

local function _lsp_setup(server)
  if not server or already_setup[server] then
    return
  end
  already_setup[server] = true
  local ok, opts = pcall(require, 'config/lsp/'..server)
  if not ok then
    opts = {}
  end
  lspconfig[server].setup(opts)
end

local lsp_setup = function(event)
  local ext = vim.fn.fnamemodify(event.file, ':e')
  _lsp_setup(ext_to_lsp_server(ext))
end

vim.diagnostic.config({signs = false})
vim.diagnostic.config({underline = false})
-- Hide all semantic highlights
for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
  vim.api.nvim_set_hl(0, group, {})
end

vim.api.nvim_create_autocmd('BufReadPre', { callback = lsp_setup; })
