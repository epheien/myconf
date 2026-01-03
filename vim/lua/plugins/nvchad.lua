-- nvchad 的一些组件, 主要是主题

return {
  {
    'nvchad/ui',
    lazy = true,
    config = function() require('nvchad') end,
    dependencies = {
      'nvchad/ui',
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'epheien/volt',
    },
  },

  {
    'nvchad/base46',
    lazy = true,
    --build = function() require('base46').load_all_highlights() end,
  },
}
