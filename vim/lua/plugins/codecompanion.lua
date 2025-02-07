return {
  'olimorris/codecompanion.nvim',
  cmd = { 'CodeCompanion', 'CodeCompanionCmd', 'CodeCompanionChat', 'CodeCompanionActions' },
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-lua/plenary.nvim',
    'j-hui/fidget.nvim',
  },
  config = function() require('plugins.config.codecompanion') end,
  init = function() require('plugins.config.fidget-spinner'):init() end,
}
