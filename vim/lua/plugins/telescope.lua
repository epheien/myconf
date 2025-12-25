return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'debugloop/telescope-undo.nvim',
    'ukyouz/telescope-gtags',
    'epheien/ai-prompts.nvim',
  },
  cmd = 'Telescope',
  config = function()
    require('plugins.config.telescope')
  end,
}
