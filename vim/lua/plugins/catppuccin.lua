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
    vim.api.nvim_create_autocmd('ColorScheme', {
      pattern = {
        'catppuccin',
        'catppuccin-latte',
        'catppuccin-frappe',
        'catppuccin-macchiato',
        'catppuccin-mocha',
      },
      callback = function(event) ---@diagnostic disable-line: unused-local
        vim.api.nvim_set_hl(0, 'NvimTreeStatuslineNc', { link = 'StatusLineNC' })
      end,
    })
    vim.api.nvim_exec_autocmds('ColorScheme', { modeline = false, pattern = vim.g.colors_name })
  end,
}
