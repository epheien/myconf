return {
  'folke/tokyonight.nvim',
  lazy = vim.g.my_colors_name ~= 'tokyonight',
  priority = 1000,
  config = function()
    require('tokyonight').setup({})
    require('tokyonight').load()
    vim.api.nvim_exec_autocmds('ColorScheme', { modeline = false })
  end,
}
