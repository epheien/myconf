local loaded_plugins = {
  'neo-tree',
}

local M = {}

for _, name in ipairs(loaded_plugins) do
  table.insert(M, require('plugins.' .. name))
end

return M
