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
    require('snacks').setup(opts)
    vim.api.nvim_set_hl(0, 'SnacksDashboardHeader', { link = 'Directory' })
    vim.api.nvim_set_hl(0, 'SnacksDashboardDesc', { link = 'Normal' })
  end,
}
