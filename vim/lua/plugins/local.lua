local function process_local_plugins(plugins)
  ---@diagnostic disable-next-line
  local base_dir = vim.fs.joinpath(vim.fn.stdpath('config'), 'plugpack')
  for idx, plugin in ipairs(plugins) do
    if type(plugin) == 'string' then
      plugins[idx] = vim.fs.joinpath(base_dir, plugin)
    else
      plugin[1] = vim.fs.joinpath(base_dir, plugin[1])
    end
  end
  return plugins
end


local local_plugins = {
  --'common',
  'vim-repeat',
  'python-syntax',
  { 'mymark',    keys = { { { 'n', 'x' }, '<Plug>MarkSet' }, '<Plug>MarkAllClear' } },
  { 'jsonfmt',   cmd = 'JsonFmt' },
  { 'colorizer', cmd = 'UpdateColor' },
  { 'colorsel',  cmd = 'ColorSel' },
  { 'visincr',   keys = 'I' }
}

return process_local_plugins(local_plugins)
