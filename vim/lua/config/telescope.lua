local function setup_telescope()
  local opts = {
    -- Default configuration for telescope goes here:
    -- config_key = value,
    mappings = {
      i = {
        ["<Esc>"] = require('telescope.actions').close,
        ["<C-j>"] = require('telescope.actions').move_selection_next,
        ["<C-k>"] = require('telescope.actions').move_selection_previous,
        ["<C-l>"] = false,
        ["<C-u>"] = false,
        ["<C-b>"] = require('telescope.actions').preview_scrolling_up,
        ["<C-f>"] = require('telescope.actions').preview_scrolling_down,
      }
    },
    sorting_strategy = "ascending",
    layout_config = {
      prompt_position = 'top',
    },
  }
  require('telescope').setup({
    --defaults = require('telescope.themes').get_dropdown(opts),
    defaults = opts,
    pickers = {
      tags = {
        only_sort_tags = true,
      },
      current_buffer_tags = {
        only_sort_tags = true,
      },
      find_files = {
        no_ignore = true,
        no_ignore_parent = true,
      },
    },
  })
  vim.api.nvim_set_hl(0, 'TelescopeBorder', {link = 'WinSeparator', force = true})
  vim.api.nvim_set_hl(0, 'TelescopeTitle', {link = 'Title', force = true})
  -- telescope 的 undo 插件
  require("telescope").load_extension("undo")
end

setup_telescope()
