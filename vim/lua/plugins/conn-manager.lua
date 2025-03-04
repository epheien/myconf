local function on_node_open(node, fallback, opts)
  local empty = require('utils').empty
  if not opts or empty(opts.open_with) then
    fallback()
    return
  end
  if opts.open_with == 'tab' then
    require('conn-manager').open_in_tab()
    vim.api.nvim_set_option_value('winfixbuf', true, { win = 0 })
    vim.t.title = node.config.display_name
    return
  end
  local title = node.config.display_name
  -- dump args to execute
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

---@param obj wintab.Wintab
---@return wintab.Component[]
local function get_buffer_components(obj) ---@diagnostic disable-line
  local components = {}
  for _, job in ipairs(require('conn-manager').tree.jobs) do
    table.insert(
      components,
      require('wintab').Component.new(
        job.bufnr,
        string.format(' %s ', vim.b[job.bufnr].conn_manager_title)
      )
    )
  end
  return components
end

local wintab = { state = {} }
local function window_picker(node)
  local winid = -1
  if wintab.state.winid and vim.api.nvim_win_is_valid(wintab.state.winid) then
    winid = wintab.state.winid
  end
  if vim.api.nvim_win_is_valid(winid) then
    if not require('conn-manager.window').is_window_usable(winid) then
      vim.api.nvim_win_set_buf(winid, vim.api.nvim_create_buf(true, true))
    end
    goto out
  end
  winid = require('conn-manager.window').pick_window_for_node_open(false)
  if winid == -1 then
    vim.cmd.tabnew()
    vim.api.nvim_set_option_value('winfixbuf', true, { win = 0 })
    vim.t.title = node.config.display_name
    winid = vim.api.nvim_get_current_win()
  end
  ::out::
  if vim.api.nvim_get_option_value('winbar', { win = winid }) == '' then
    wintab = require('wintab').init(winid, get_buffer_components)
  end
  return winid
end

return {
  'epheien/conn-manager.nvim',
  cmd = 'ConnManager',
  dependencies = {
    'epheien/wintab.nvim',
    'nvchad/menu',
  },
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
        vim.api.nvim_set_option_value('winfixbuf', true, { win = win })
      end,
      node = {
        on_open = on_node_open,
        window_picker = window_picker,
      },
      on_buffer_create = function(bufnr)
        vim.keymap.set(
          'n',
          't',
          function() require('conn-manager').open({ open_with = 'tab' }) end,
          { buffer = bufnr, desc = 'Open in Tab' }
        )
        vim.keymap.set(
          'n',
          '.',
          function() require('menu').open('conn-manager', { mouse = false, border = false }) end,
          { buffer = bufnr, desc = 'Menu' }
        )
      end,
      save = {
        on_read = function(text) return text end,
        on_write = function(text)
          if not vim.fn.executable('jq') then
            return text
          end
          vim.system({ 'jq' }, {
            stdin = text,
          }, function(obj)
            if obj.code ~= 0 then
              vim.api.nvim_err_writeln(string.format('jq exit %d: %s', obj.code, obj.stderr))
              return
            end
            local fname = require('conn-manager.config').config.config_file
            local temp = fname .. '.tmp'
            local file = io.open(temp, 'w')
            if file then
              file:write(obj.stdout)
              file:close()
              os.rename(temp, fname)
            end
          end)
        end,
      },
    })
  end,
}
