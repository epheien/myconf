return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  requires = { 'nvim-lua/plenary.nvim', 'debugloop/telescope-undo.nvim', 'nvim-tree/nvim-web-devicons' },
  cmd = 'Telescope',
  config = function() require('plugins.config.telescope') end,
}
