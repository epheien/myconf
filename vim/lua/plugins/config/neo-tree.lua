require('neo-tree').setup({
  open_file_with_relative = true,
  window = {
    width = 36,
    mappings = {
      ['<space>'] = 'noop',
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
