-- 读取 vimrc
--local vimrc = vim.fn.stdpath("config") .. "/vimrc"
--vim.cmd.source(vimrc)

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- ========================================
-- nvim-tree.lua
-- ========================================
local tree_actions = {
  {
    name = "Create",
    handler = require("nvim-tree.api").fs.create,
  },
  {
    name = "Delete",
    handler = require("nvim-tree.api").fs.remove,
  },
  {
    name = "Trash",
    handler = require("nvim-tree.api").fs.trash,
  },
  {
    name = "Rename",
    handler = require("nvim-tree.api").fs.rename,
  },
  {
    name = "Rename: Omit Filename",
    handler = require("nvim-tree.api").fs.rename_sub,
  },
  {
    name = "Copy",
    handler = require("nvim-tree.api").fs.copy.node,
  },
  {
    name = "Paste",
    handler = require("nvim-tree.api").fs.paste,
  },
  {
    name = "Run Command",
    handler = require("nvim-tree.api").node.run.cmd,
  },
}

local function tree_actions_menu(node)
  local entry_maker = function(menu_item)
    return {
      value = menu_item,
      ordinal = menu_item.name,
      display = menu_item.name,
    }
  end

  local finder = require("telescope.finders").new_table({
    results = tree_actions,
    entry_maker = entry_maker,
  })

  local sorter = require("telescope.sorters").get_generic_fuzzy_sorter()

  local default_options = {
    finder = finder,
    sorter = sorter,
    attach_mappings = function(prompt_buffer_number)
      local actions = require("telescope.actions")

      -- On item select
      actions.select_default:replace(function()
        local state = require("telescope.actions.state")
        local selection = state.get_selected_entry()
        -- Closing the picker
        actions.close(prompt_buffer_number)
        -- Executing the callback
        selection.value.handler(node)
      end)

      -- The following actions are disabled in this example
      -- You may want to map them too depending on your needs though
      actions.add_selection:replace(function() end)
      actions.remove_selection:replace(function() end)
      actions.toggle_selection:replace(function() end)
      actions.select_all:replace(function() end)
      actions.drop_all:replace(function() end)
      actions.toggle_all:replace(function() end)

      return true
    end,
  }

  -- Opening the menu
  require("telescope.pickers").new({ prompt_title = "Tree Menu" }, default_options):find()
end

local function my_on_attach(bufnr)
  local api = require('nvim-tree.api')

  local function opts(desc)
    return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  api.config.mappings.default_on_attach(bufnr)

  -- your removals and mappings go here
  vim.keymap.set("n", ".", tree_actions_menu, opts("nvim tree menu"))
  vim.keymap.del('n', 'g?', opts('Help'))
  vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))
  vim.keymap.set('n', 'p', api.node.navigate.parent, opts('Parent Directory'))
end

require("nvim-tree").setup({
  sort_by = "case_sensitive",
  git = {
    enable = false,
  },
  view = {
    width = 31,
    signcolumn = "auto",
  },
  renderer = {
    group_empty = true,
    icons = {
      git_placement = "after",
    },
  },
  filters = {
    dotfiles = true,
  },
  actions = {
    open_file = {
      window_picker = {
        enable = true,
        picker = vim.fn['myrc#GetWindowIdForNvimTreeToOpen'],
      },
    },
  },
  on_attach = my_on_attach,
})
-- ----------------------------------------

require("indent_blankline").setup({
})

require('telescope').setup{
  defaults = {
    -- Default configuration for telescope goes here:
    -- config_key = value,
    mappings = {
      i = {
        --["<Esc>"] = require('telescope.actions').close,
        ["<C-j>"] = require('telescope.actions').move_selection_next,
        ["<C-k>"] = require('telescope.actions').move_selection_previous,
      }
    }
  },
}

local ok, noice_mod = pcall(require, 'noice')
if ok then
  noice_mod.setup({
    cmdline = {
      format = {
        help = false,
        lua = false,
        filter = false,
        --search_down = { icon = "/ ⌄" },
        --search_up = { icon = "? ⌃" },
      },
    },
    messages = {
      enabled = true,
      view = 'mini',
      view_error = 'mini',
      view_warn = 'mini',
      view_history = 'popup',
    },
    commands = {
      history = {
        view = 'popup',
      },
    },
    format = {
      level = {
        icons = {
          error = "✖",
          warn = "▼",
          info = "●",
        },
      },
    },
  })
end
