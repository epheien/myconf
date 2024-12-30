require('neo-tree').setup({
  open_file_with_relative = true,
  window = {
    width = 36,
    mappings = {
      ['<space>'] = 'noop',
    },
  },
})
vim.api.nvim_set_hl(0, 'NeoTreeDirectoryIcon', { fg = '#8094b4', ctermfg = 12 })
vim.api.nvim_set_hl(0, 'NeoTreeDirectoryName', { link = 'Title' })
vim.api.nvim_set_hl(0, 'NeoTreeRootName', { bold = true })

local opts = vim.api.nvim_get_hl(0, { name = 'NeoTreeGitUntracked' })
opts.italic = false ---@diagnostic disable-line
vim.api.nvim_set_hl(0, 'NeoTreeGitUntracked', opts) ---@diagnostic disable-line
