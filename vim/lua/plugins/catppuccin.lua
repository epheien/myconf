local opts = {
  flavour = 'macchiato', -- latte, frappe, macchiato, mocha (浅色 => 深色)
  no_italic = true,
}

return {
  'catppuccin/nvim',
  name = 'catppuccin',
  priority = 1000,
  lazy = vim.g.my_colors_name ~= 'catppuccin',
  config = function()
    require('catppuccin').setup(opts)
    require('catppuccin').load()
    vim.api.nvim_exec_autocmds('ColorScheme', { modeline = false })
  end,
}
