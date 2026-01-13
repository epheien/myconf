return {
  'olimorris/codecompanion.nvim',
  cmd = { 'CodeCompanionChat' },
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-lua/plenary.nvim',
    'j-hui/fidget.nvim',
    'ravitemer/codecompanion-history.nvim',
  },
  config = function()
    require('plugins.config.fidget-spinner'):init()
    require('plugins.config.codecompanion')
  end,
  --init = function() require('plugins.config.fidget-spinner'):init() end,
}
