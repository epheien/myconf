return {
  --'nvim-tree/nvim-tree.lua',
  'epheien/nvim-tree.lua',
  requires = { 'nvim-tree/nvim-web-devicons', 'nvim-telescope/telescope.nvim' },
  cmd = { 'NvimTreeOpen', 'NvimTreeToggle' },
  config = function() require('plugins.config.nvim-tree') end,
}
