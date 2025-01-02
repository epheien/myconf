local utils = require('utils')

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

-- 禁用斜体
utils.modify_hl('NeoTreeRootName', { italic = false })
utils.modify_hl('NeoTreeGitUntracked', { italic = false })
