return {
  {
    'neovim/nvim-lspconfig',
    event = { 'FileType' },
    config = function() require('plugins.config.nvim-lspconfig') end,
    dependencies = { 'ray-x/lsp_signature.nvim' }, -- 需要在 lsp attach 之前加载
  },
  {
    --'hrsh7th/nvim-cmp',
    'epheien/nvim-cmp', -- 使用自己的版本
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'onsails/lspkind.nvim',
      'epheien/cmp-buffer',
      'hrsh7th/cmp-path',
      'epheien/cmp-cmdline',
      --'hrsh7th/vim-vsnip',
      --'hrsh7th/cmp-vsnip',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'rafamadriz/friendly-snippets',
      --'garymjr/nvim-snippets',
      --'windwp/nvim-autopairs',
    },
    event = { 'InsertEnter', 'CmdlineEnter' },
    cmd = 'CmpDisable',
    keys = { ':', '/', '?' },
    config = function()
      require('plugins.config.nvim-cmp')
      require('luasnip.loaders.from_vscode').lazy_load({
        paths = { vim.fn.stdpath('config') .. '/snippets' },
      })
      --require('cmp').event:on('confirm_done', require('nvim-autopairs.completion.cmp').on_confirm_done())
    end,
  },
  {
    'epheien/lsp_signature.nvim',
    keys = '<Plug>lsp-signature',
    opts = {
      handler_opts = { border = 'single' },
      max_width = 80,
      floating_window_off_x = -1,
      zindex = 2,
      hint_enable = false,
    },
  },
}
