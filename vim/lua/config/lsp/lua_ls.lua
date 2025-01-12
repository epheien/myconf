local util = require('lspconfig.util')

-- NOTE: 默认情况下, 匹配顺序是从下层到上层的每个路径匹配第一个文件模式, 例如 .luarc.json
--       然后再下一个文件模式, .luarc.jsonc, ..., 真的有点坑

local root_files = {
  '.luarc.json',
  '.luarc.jsonc',
  '.luacheckrc',
  '.stylua.toml',
  'stylua.toml',
  'selene.toml',
  'selene.yml',
}

return {
  root_dir = function(fname)
    -- 简单的 hack 优先支持当前路径
    for _, file in ipairs(root_files) do
      if vim.uv.fs_stat(file) then
        return vim.fn.getcwd()
      end
    end
    return require('lspconfig.configs.lua_ls').default_config.root_dir(fname)
  end,
  on_init = function(client)
    --local path = client.workspace_folders[1].name
    --if vim.loop.fs_stat(path..'/.luarc.json') or vim.loop.fs_stat(path..'/.luarc.jsonc') then
    --  return
    --end

    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      runtime = {
        -- Tell the language server which version of Lua you're using
        -- (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      -- Make the server aware of Neovim runtime files
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          -- Depending on the usage, you might want to add additional paths here.
          -- "${3rd}/luv/library"
          -- "${3rd}/busted/library",
        },
        -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
        -- library = vim.api.nvim_get_runtime_file("", true)
      },
    })
  end,
  settings = {
    Lua = {},
  },
}
