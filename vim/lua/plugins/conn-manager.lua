return {
  'epheien/conn-manager.nvim',
  cmd = 'ConnManagerOpen',
  config = function()
    require('conn-manager').setup({
      config_file = vim.fs.joinpath(vim.fn.stdpath('config') --[[@as string]], 'conn-manager.json'),
      window_config = {
        width = 36,
        split = 'left',
        vertical = true,
        win = -1,
      },
      on_window_open = function(win)
        vim.api.nvim_set_option_value('statusline', '─', { win = win })
        vim.api.nvim_set_option_value('fillchars', vim.o.fillchars .. ',eob: ', { win = win })
      end,
    })
  end,
}
