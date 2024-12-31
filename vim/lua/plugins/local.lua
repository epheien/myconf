local function process_local_plugins(plugins)
  ---@diagnostic disable-next-line
  local base_dir = vim.fs.joinpath(vim.fn.stdpath('config'), 'plugpack')
  local pckr = vim.g.package_manager == 'pckr'
  for idx, plugin in ipairs(plugins) do
    if type(plugin) == 'string' then
      if pckr then
        plugins[idx] = vim.fs.joinpath(base_dir, plugin)
      else
        plugins[idx] = { dir = vim.fs.joinpath(base_dir, plugin) }
      end
    else
      if pckr then
        plugin[1] = vim.fs.joinpath(base_dir, plugin[1])
      else
        plugin.dir = vim.fs.joinpath(base_dir, plugin[1])
        plugin[1] = nil
      end
    end
  end
  return plugins
end

local local_plugins = {
  --'common',
  'vim-repeat',
  'python-syntax',
  { 'mymark',    keys = { { '<Plug>MarkSet', mode = { 'n', 'x' } }, '<Plug>MarkAllClear' } },
  { 'jsonfmt',   cmd = 'JsonFmt' },
  { 'colorizer', cmd = 'UpdateColor' },
  { 'colorsel',  cmd = 'ColorSel' },
  { 'visincr',   keys = 'I' },
}

return process_local_plugins(local_plugins)
