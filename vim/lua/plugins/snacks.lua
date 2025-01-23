local opts = {
  styles = {
    dashboard = {
      wo = {
        --winhighlight = 'Normal:SnacksDashboardNormal,NormalFloat:SnacksDashboardNormal,Title:Directory',
        fillchars = 'eob: ', -- end of buffer 填充的字符, 默认为 ~
      },
    },
    notification = {
      border = 'single',
      title_pos = 'left',
      ft = '',
    },
    notification_history = {
      border = 'single',
      ft = '',
    },
    float = {
      backdrop = false
    }
  },

  notifier = {
    --enabled = false,
    timeout = 4000,
    width = { min = 20, max = 0.999 },
    date_format = '%T',
  },

  dashboard = {
    enabled = not vim.g.nodashboard,
    preset = {
      -- stylua: ignore
      keys = {
        { icon = " ", key = "F", desc = "File Manager", action = ":enew | NvimTreeOpen" },
        { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
        { icon = " ", key = "n", desc = "New File", action = ":ene" },
        --{ icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
        { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
        { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
        { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
      },
    },

    sections = {
      { section = 'header' },
      { section = 'keys', gap = 1, padding = 1 },
      { section = 'startup' },
    },
  },
}

if false then
  opts.dashboard.sections[1] = {
    section = 'terminal',
    --cmd = 'chafa vscode-neovim.png --format symbols --symbols vhalf --size 20x10 --stretch; sleep .1',
    cmd = string.format(
      'cat \'%s\'; sleep .1',
      ---@diagnostic disable-next-line
      vim.fs.joinpath(vim.fn.stdpath('config'), 'images', 'logo_cat.cat')
    ),
    height = 17,
    padding = 1,
    indent = 5,
    ttl = math.huge, -- 缓存有效时间, 单位是秒
  }
end

return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  config = function()
    local notify = vim.notify
    require('snacks').setup(opts)
    -- HACK: restore vim.notify after snacks setup and let noice.nvim take over
    -- this is needed to have early notifications show up in noice history
    vim.notify = notify
    vim.api.nvim_create_user_command(
      'SnacksNotifierHistory',
      function() require('snacks.notifier').show_history() end,
      { nargs = 0 }
    )
  end,
}
