local function on_node_open(node, fallback, opts) ---@diagnostic disable-line
  local empty = require('utils').empty
  if not opts or empty(opts.open_with) then
    fallback()
    return
  end
  local title = node.config.display_name
  -- @提取需要运行的命令
  local args = { 'ssh' }
  if node.config.port then
    vim.list_extend(args, { '-p', tostring(node.config.port) })
  end
  if not empty(node.config.username) then
    vim.list_extend(args, { '-l', node.config.username })
  end
  if not empty(node.config.private_key_file) then
    vim.list_extend(args, { '-i', vim.fn.expand(node.config.private_key_file) })
  end
  table.insert(args, node.config.computer_name)
  local prefix
  if opts.open_with == 'kitty' then
    prefix = { 'open', '-n', '-a', 'kitty', '--args', '--title', title }
  else
    prefix = { 'open', '-n', '-a', 'alacritty', '--args', '--title', title, '-e' }
  end
  args = vim.list_extend(prefix, args)
  vim.system(args, { stdout = false, stderr = false, detach = true })
end

return {
  'epheien/conn-manager.nvim',
  cmd = 'ConnManagerOpen',
  config = function()
    require('conn-manager').setup({
      config_file = vim.fs.joinpath(vim.fn.stdpath('config') --[[@as string]], 'conn-manager.json'),
      window_config = {
        width = 36,
        split = 'left',
        vertical = true,
        win = -1,
      },
      on_window_open = function(win)
        vim.api.nvim_set_option_value('statusline', '─', { win = win })
        vim.api.nvim_set_option_value('fillchars', vim.o.fillchars .. ',eob: ', { win = win })
      end,
      node = {
        on_open = on_node_open,
      },
      on_buffer_create = function(bufnr)
        vim.keymap.set(
          'n',
          '.',
          function() require('menu').open('conn-manager', { mouse = false, border = false }) end,
          { buffer = bufnr }
        )
      end,
    })
  end,
}
