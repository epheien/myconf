local function extra_load()
  require('onedark-nvchad').extra_load()
  vim.api.nvim_exec_autocmds('ColorScheme', { modeline = false, pattern = vim.g.colors_name })
end

return {
  ---@diagnostic disable-next-line
  dir = vim.fs.joinpath(vim.fn.stdpath('config'), 'plugpack', 'onedark-nvchad'),
  priority = 1000,
  lazy = vim.g.my_colors_name ~= 'onedark-nvchad',
  config = function()
    vim.g.colors_name = 'onedark-nvchad'
    require('onedark-nvchad').setup({ style = 'soft' })
    if vim.fn.argc(-1) > 0 then
      require('onedark-nvchad').load()
      vim.api.nvim_exec_autocmds('ColorScheme', { modeline = false, pattern = vim.g.colors_name })
    else
      require('onedark-nvchad').base_load()
      -- MyLazyEvent 用于同步自用的事件
      vim.api.nvim_create_autocmd(
        'User',
        { pattern = {'VeryLazy', 'MyLazyEvent'}, once = true, callback = extra_load }
      )
    end
  end,
}
