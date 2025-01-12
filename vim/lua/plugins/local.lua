local function process_local_plugins(plugins)
  ---@diagnostic disable-next-line
  local base_dir = vim.fs.joinpath(vim.fn.stdpath('config'), 'plugpack')
  for idx, plugin in ipairs(plugins) do
    if type(plugin) == 'string' then
      plugins[idx] = { dir = vim.fs.joinpath(base_dir, plugin) }
    else
      plugin.dir = vim.fs.joinpath(base_dir, plugin[1])
      plugin[1] = nil
    end
  end
  return plugins
end

local local_plugins = {
  { 'vim-repeat', event = 'VeryLazy' },
  { 'python-syntax', event = 'VeryLazy' },
  { 'jsonfmt', cmd = 'JsonFmt' },
  { 'colorsel', cmd = 'ColorSel' },
  { 'visincr', keys = 'I' },
}

return process_local_plugins(local_plugins)
