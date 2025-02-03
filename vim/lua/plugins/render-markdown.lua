return {
  'MeanderingProgrammer/render-markdown.nvim',
  ft = { 'markdown', 'Avante' },
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
  opts = {
    -- Whether Markdown should be rendered by default or not
    enabled = true,
    file_types = { 'markdown', 'Avante' },
    code = {
      enabled = true,
      sign = false,
    },
    heading = {
      sign = false,
    },
    dash = {
      icon = '━',
    },
  },
}
