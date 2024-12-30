local function setup_lualine() -- {{{
  vim.opt.laststatus = 2
  vim.opt.showmode = false

  local theme = {
    normal = {
      a = { fg = '#282828', bg = '#8ac6f2' }, -- "模式 文件 | 位置" 后两者的颜色
      c = { fg = "#665c54", bg = "NONE" },    -- 填充色
    },
    inactive = { a = { fg = '#282828', bg = '#6a6a6a' } },
  }
  local color_map = {
    i = { fg = '#282828', bg = '#95e454' },
    t = { fg = '#282828', bg = '#95e454' },
    v = { fg = '#282828', bg = '#f2c68a' },
    s = { fg = '#282828', bg = '#f2c68a' },
    r = { fg = '#282828', bg = '#e5786d' },
  }
  local mode_color = function()
    return color_map[vim.fn.mode():sub(1, 1):lower()] or { fg = '#282828', bg = '#e0e000' }
  end
  local location = function()
    return vim.api.nvim_eval_statusline('%l/%L,%v', { winid = vim.fn.win_getid() })['str']
  end
  local opts = {
    options = {
      component_separators = { left = '│', right = '│' },
      theme = theme,
    },
    sections = {
      lualine_a = { { 'mode', separator = '', color = mode_color }, 'filename', location },
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {},
    },
    inactive_sections = {
      lualine_a = { 'filename', location },
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {}
    },
    tabline = {},
    winbar = {},
  }
  require('lualine').setup(opts)
end
-- }}}

setup_lualine()
