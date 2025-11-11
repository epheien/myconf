local lspconfig = require('lspconfig')

local inited = {}

-- lsp server 对应的扩展名, 不存在就不会启动 lsp
-- ext 事实为 filetype, 已经优化为使用文件类型映射到 lsp
-- key 对应于 nvim-lspconfig 的模块名称, value 对应于文件类型
local server_exts = {
  clangd = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
  lua_ls = { 'lua' },
  basedpyright = { 'python' },
  gopls = { 'go' },
  cmake = { 'cmake' },
  rust_analyzer = { 'rust' },
}

local already_setup = {}
local ext_to_server = {}

local if_nil = function(val, default)
  if val == nil then return default end
  return val
end

local default_capabilities = function(override)
  override = override or {}

  return {
    textDocument = {
      completion = {
        dynamicRegistration = if_nil(override.dynamicRegistration, false),
        completionItem = {
          snippetSupport = if_nil(override.snippetSupport, true),
          commitCharactersSupport = if_nil(override.commitCharactersSupport, true),
          deprecatedSupport = if_nil(override.deprecatedSupport, true),
          preselectSupport = if_nil(override.preselectSupport, true),
          tagSupport = if_nil(override.tagSupport, {
            valueSet = {
              1, -- Deprecated
            }
          }),
          insertReplaceSupport = if_nil(override.insertReplaceSupport, true),
          resolveSupport = if_nil(override.resolveSupport, {
              properties = {
                  "documentation",
                  "detail",
                  "additionalTextEdits",
                  "sortText",
                  "filterText",
                  "insertText",
                  "textEdit",
                  "insertTextFormat",
                  "insertTextMode",
              },
          }),
          insertTextModeSupport = if_nil(override.insertTextModeSupport, {
            valueSet = {
              1, -- asIs
              2, -- adjustIndentation
            }
          }),
          labelDetailsSupport = if_nil(override.labelDetailsSupport, true),
        },
        contextSupport = if_nil(override.snippetSupport, true),
        insertTextMode = if_nil(override.insertTextMode, 1),
        completionList = if_nil(override.completionList, {
          itemDefaults = {
            'commitCharacters',
            'editRange',
            'insertTextFormat',
            'insertTextMode',
            'data',
          }
        })
      },
    },
  }
end

local open_floating_preview = vim.lsp.util.open_floating_preview
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.util.open_floating_preview = function(contents, syntax, opts)
  local bak = vim.g.syntax_on
  vim.g.syntax_on = nil
  local floating_bufnr, floating_winnr = open_floating_preview(contents, syntax, opts)
  vim.g.syntax_on = bak
  if syntax == 'markdown' then
    vim.wo[floating_winnr].conceallevel = 2
  end
  return floating_bufnr, floating_winnr
end

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
  local capabilities = vim.tbl_deep_extend(
    'force',
    {},
    --vim.lsp.protocol.make_client_capabilities(),
    default_capabilities({
      snippetSupport = false,
    }))
  opts = vim.tbl_deep_extend('force', opts, {
    capabilities = capabilities,
  })
  lspconfig[server].setup(opts)
end

local lsp_setup = function(event)
  local ext = event.match
  if inited[ext] then
    return
  end
  inited[ext] = true
  _lsp_setup(ext_to_lsp_server(ext))
  -- 必须重发一次 autocmd, 否则 lspconfig 无法正确工作
  vim.api.nvim_exec_autocmds(event.event, {buffer = event.buf, modeline = false})
end

vim.diagnostic.config({signs = false})
vim.diagnostic.config({underline = false})
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    client.server_capabilities.semanticTokensProvider = nil
  end,
});

vim.api.nvim_create_autocmd('FileType', { callback = lsp_setup })
-- 关闭 lsp 日志, 仅在需要的时候再开启, 最终都需要关闭
vim.lsp.set_log_level('OFF')
