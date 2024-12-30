local loaded_plugins = {
  'local',
  'vim-plugins',
  'neo-tree',
}

local M = {}

for _, name in ipairs(loaded_plugins) do
  local mod = require('plugins.' .. name)
  if vim.islist(mod) then
    vim.list_extend(M, mod)
  else
    table.insert(M, mod)
  end
end

return M
