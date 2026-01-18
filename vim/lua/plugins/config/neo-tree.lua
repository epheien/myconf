vim.api.nvim_set_hl(0, 'NeoTreeFloatBorder', { link = 'FloatBorder' })
vim.api.nvim_set_hl(0, 'NeoTreeFloatNormal', { link = 'Normal' })
vim.api.nvim_set_hl(0, 'NeoTreeRootName', { bold = true })

require('neo-tree').setup({
  open_files_using_relative_paths = true,
  popup_border_style = 'single',
  window = {
    width = 36,
    mappings = {
      ['<space>'] = 'noop',
    },
    popup = {
      title = 'Neo-tree Filesystem', -- title 无效, NuiPopup 的限制
      border = 'single',
    },
  },
  filesystem = {
    filtered_items = {
      hide_dotfiles = false,
      hide_gitignored = false,
      hide_hidden = false,
    },
  },
})
