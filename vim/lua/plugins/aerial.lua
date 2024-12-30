return {
  'stevearc/aerial.nvim',
  cmd = 'AerialToggle',
  opts = {
    layout = {
      max_width = 30,
      min_width = 30,
      default_direction = 'right',
      placement = 'edge',
      resize_to_content = false,
      attach_mode = 'global',
    },
    keymaps = {
      ["<C-j>"] = false,
      ["<C-k>"] = false,
    },
  }
}
