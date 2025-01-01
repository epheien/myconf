local opts = {
  styles = {
    dashboard = {
      wo = {
        --winhighlight = 'Normal:SnacksDashboardNormal,NormalFloat:SnacksDashboardNormal,Title:Directory',
        fillchars = 'eob: ', -- end of buffer 填充的字符, 默认为 ~
      },
    },
  },

  dashboard = {
    enabled = not vim.g.nodashboard,
    preset = {
      -- stylua: ignore
      keys = {
        { icon = " ", key = "F", desc = "Find Manager", action = ":enew | NvimTreeOpen" },
        { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
        { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
        { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
        { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
        { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
        { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
      },
    },
  },
}

return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  config = function()
    require('snacks').setup(opts)
    vim.api.nvim_set_hl(0, 'SnacksDashboardHeader', { link = 'Directory' })
  end,
}
