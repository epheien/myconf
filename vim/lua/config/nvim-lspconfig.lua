local lspconfig = require('lspconfig')

local already_setup = {}

local ext_map = {
  cpp = 'clangd',
  lua = 'lua_ls',
  py = 'pyright',
}

-- 扩展名映射到 lsp 服务器名称
local function ext_to_lsp_server(ext)
  return ext_map[ext]
end

-- TODO: setup() 的懒加载
local lsp_setup = function(event)
  local ext = vim.fn.fnamemodify(event.file, ':e')
  local server = ext_to_lsp_server(ext)
  if not server then
    return
  end
  if server == 'pyright' and not already_setup[server] then
    already_setup[server] = true
    lspconfig.pyright.setup({})
  elseif server == 'lua_ls' and not already_setup[server] then
    already_setup[server] = true
    lspconfig.lua_ls.setup({
      on_init = function(client)
        local path = client.workspace_folders[1].name
        if vim.loop.fs_stat(path..'/.luarc.json') or vim.loop.fs_stat(path..'/.luarc.jsonc') then
          return
        end

        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
          runtime = {
            -- Tell the language server which version of Lua you're using
            -- (most likely LuaJIT in the case of Neovim)
            version = 'LuaJIT'
          },
          -- Make the server aware of Neovim runtime files
          workspace = {
            checkThirdParty = false,
            library = {
              vim.env.VIMRUNTIME
              -- Depending on the usage, you might want to add additional paths here.
              -- "${3rd}/luv/library"
              -- "${3rd}/busted/library",
            }
            -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
            -- library = vim.api.nvim_get_runtime_file("", true)
          }
        })
      end,
      settings = {
        Lua = {}
      }
    })
  elseif server == 'clangd' and not already_setup[server] then
    already_setup[server] = true
    lspconfig.clangd.setup({
      cmd = {
        'clangd',
        '--header-insertion=never', -- NOTE: 添加这个选项后, '•' 前缀变成了 ' ', 需要自己过滤掉
        --'--header-insertion-decorators',
      },
    })
  end
end
vim.diagnostic.config({signs = false})
vim.diagnostic.config({underline = false})
-- Hide all semantic highlights
for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
  vim.api.nvim_set_hl(0, group, {})
end

vim.api.nvim_create_autocmd('BufReadPre', { callback = lsp_setup; })
