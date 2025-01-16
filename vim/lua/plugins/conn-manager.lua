return {
  'epheien/conn-manager.nvim',
  cmd = 'ConnManagerOpen',
  config = function()
    require('conn-manager').setup({
      config_path = vim.fs.joinpath(vim.fn.stdpath('config') --[[@as string]], 'conn-manager.json'),
      on_window_open = function(win)
        vim.api.nvim_set_option_value('statusline', '─', { win = win })
        vim.api.nvim_set_option_value('fillchars', vim.o.fillchars .. ',eob: ', { win = win })
      end,
    })
  end,
}
