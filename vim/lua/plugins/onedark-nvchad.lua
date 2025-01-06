return {
  ---@diagnostic disable-next-line
  dir = vim.fs.joinpath(vim.fn.stdpath('config'), 'plugpack', 'onedark-nvchad'),
  priority = 1000,
  lazy = vim.g.my_colors_name ~= 'onedark-nvchad',
  config = function()
    require('onedark-nvchad').load()
    vim.g.colors_name = 'onedark-nvchad'
    vim.api.nvim_exec_autocmds('ColorScheme', { modeline = false, pattern = vim.g.colors_name })
  end,
}
