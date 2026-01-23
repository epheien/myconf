return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  opts = {
    preset = 'helix',
    win = {
      border = 'single',
      wo = {
        winhighlight = 'NormalFloat:Normal',
      },
    },
  },
  keys = {
    {
      '<leader>?',
      function() require('which-key').show({ global = false }) end,
      desc = 'Buffer Local Keymaps (which-key)',
    },
  },
  config = function(_plug, opts)
    vim.api.nvim_set_hl(0, 'WhichKeyTitle', { link = 'Normal' })
    vim.api.nvim_set_hl(0, 'WhichKeyNormal', { link = 'Normal' })
    require('which-key').setup(opts)
  end,
}
