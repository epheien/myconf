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
        -- mocha tabline 主题
        if opts.flavour == 'mocha' then
          vim.api.nvim_set_hl(0, 'MyTabLineSel', { fg = '#cdd6f5', bg = '#1e1e2f', bold = true })
          vim.api.nvim_set_hl(0, 'MyTabLineNotSel', { fg = '#45475b', bg = '#181826' })
          vim.api.nvim_set_hl(0, 'MyTabLineFill', { fg = '#45475b', bg = '#181826' })
          vim.api.nvim_set_hl(0, 'MyTabLineClose', { fg = '#f38ba9', bg = '#181826' })
        else
          vim.api.nvim_set_hl(0, 'MyTabLineSel', { fg = '#cad3f6', bg = '#24273b', bold = true })
          vim.api.nvim_set_hl(0, 'MyTabLineNotSel', { fg = '#494d65', bg = '#1e2031' })
          vim.api.nvim_set_hl(0, 'MyTabLineFill', { fg = '#494d65', bg = '#181826' })
          vim.api.nvim_set_hl(0, 'MyTabLineClose', { fg = '#ed8797', bg = '#1e2031' })
        end
      end,
    })
    vim.api.nvim_exec_autocmds('ColorScheme', { modeline = false, pattern = vim.g.colors_name })
  end,
}
