---@diagnostic disable-next-line
local root = vim.fs.joinpath(vim.fn.stdpath('config'), 'lua', 'plugins')

local loaded_plugins = {}

-- 自动发现需要载入的插件, 不再手动指定
for name, type in vim.fs.dir(root, {}) do
  if type == 'file' then
    local mod = name:match('(.+)%.lua$')
    if mod and mod ~= 'init' then
      table.insert(loaded_plugins, mod)
    end
  end
end
--vim.print(loaded_plugins)

local M = {}

for _, name in ipairs(loaded_plugins) do
  local mod = require('plugins.' .. name)
  if type(mod) == 'string' then
    table.insert(M, mod)
  elseif type(mod) == "table" then
    if vim.islist(mod) then
      vim.list_extend(M, mod)
    else
      table.insert(M, mod)
    end
  end
end

return M
