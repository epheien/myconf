return {
  'folke/tokyonight.nvim',
  lazy = vim.g.my_colors_name ~= 'tokyonight',
  priority = 1000,
  config = function()
    require('tokyonight').setup({
      style = 'moon', -- The theme comes in three styles, `storm`, a darker variant `night` and `day`
      styles = {
        comments = { italic = false },
        keywords = { italic = false },
      },
    })
    require('tokyonight').load()
    vim.api.nvim_exec_autocmds('ColorScheme', { modeline = false, pattern = vim.g.colors_name })
  end,
}
