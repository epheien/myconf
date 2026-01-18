-- 禁用内置的 netrw, 使用此插件替代
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local function tree_actions_menu(node)
  local tree_actions = {
    {
      name = 'Create',
      handler = require('nvim-tree.api').fs.create,
    },
    {
      name = 'Delete',
      handler = require('nvim-tree.api').fs.remove,
    },
    {
      name = 'Trash',
      handler = require('nvim-tree.api').fs.trash,
    },
    {
      name = 'Rename',
      handler = require('nvim-tree.api').fs.rename,
    },
    {
      name = 'Rename: Omit Filename (Move)',
      handler = require('nvim-tree.api').fs.rename_sub,
    },
    {
      name = 'Copy',
      handler = require('nvim-tree.api').fs.copy.node,
    },
    {
      name = 'Paste',
      handler = require('nvim-tree.api').fs.paste,
    },
    {
      name = 'Run Command',
      handler = require('nvim-tree.api').node.run.cmd,
    },
  }

  local entry_maker = function(menu_item)
    return {
      value = menu_item,
      ordinal = menu_item.name,
      display = menu_item.name,
    }
  end

  local finder = require('telescope.finders').new_table({
    results = tree_actions,
    entry_maker = entry_maker,
  })

  local sorter = require('telescope.sorters').get_generic_fuzzy_sorter()

  local default_options = {
    finder = finder,
    sorter = sorter,
    attach_mappings = function(prompt_buffer_number)
      local actions = require('telescope.actions')

      -- On item select
      actions.select_default:replace(function()
        local state = require('telescope.actions.state')
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
  require('telescope.pickers').new({ prompt_title = 'Tree Menu' }, default_options):find()
end

local function my_on_attach(bufnr)
  local api = require('nvim-tree.api')

  local function opts(desc)
    return {
      desc = 'nvim-tree: ' .. (desc or ''),
      buffer = bufnr,
      noremap = true,
      silent = true,
      nowait = true,
    }
  end

  api.config.mappings.default_on_attach(bufnr)

  -- 关键的窗口内定位快捷键不能被占用
  vim.keymap.del('n', 'H', opts('Toggle Filter: Dotfiles'))
  vim.keymap.del('n', 'M', opts('Toggle Filter: No Bookmark'))
  vim.keymap.del('n', 'L', opts('Toggle Group Empty'))
  vim.keymap.del('n', '-', opts('Up'))
  vim.keymap.del('n', 'P', opts('Parent Directory'))
  vim.keymap.del('n', 'p', opts('Paste'))
  vim.keymap.del('n', 'bt', opts())
  vim.keymap.del('n', 'bd', opts())
  vim.keymap.del('n', 'bmv', opts())

  -- 不使用的快捷键, 避免混淆/误操作
  vim.keymap.del('n', 'u', opts(''))

  -- your removals and mappings go here
  vim.keymap.del('n', '.', opts('Run Command'))
  --if pcall(require, 'telescope') then
  --  vim.keymap.set('n', '.', tree_actions_menu, opts('menu'))
  --end
  vim.keymap.set('n', '.', function() vim.api.nvim_feedkeys('Z', 't', false) end, opts('Menu'))
  vim.keymap.del('n', 'g?', opts('Help'))
  vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))
  vim.keymap.set('n', 'p', api.node.navigate.parent, opts('Parent Directory'))
  vim.keymap.set('n', '[[', api.node.navigate.parent, opts('Parent Directory'))
  vim.keymap.del('n', '<C-k>', opts('Info'))
  vim.keymap.del('n', 'U', opts('Toggle Hidden'))
  vim.keymap.del('n', '<Tab>', opts('Open Preview'))
  vim.keymap.set('n', 'i', api.node.show_info_popup, opts('Info'))
  vim.keymap.del('n', 'I', opts('Toggle Git Ignore'))
  vim.keymap.set('n', 'I', api.tree.toggle_hidden_filter, opts('Toggle Hidden'))
  vim.keymap.del('n', 'C', opts('Toggle Git Clean'))
  vim.keymap.set('n', 'C', api.tree.change_root_to_node, opts('CD'))

  vim.keymap.set('n', '@', function()
    local node = api.tree.get_node_under_cursor()
    -- 'file', 'directory'
    if node.type == 'directory' then
      return
    end
    local tree_ext = require('avante.extensions.nvim_tree')
    tree_ext.add_file()
  end, opts('Add to avante.nvim'))
end

local nvim_tree_opts = {
  on_attach = my_on_attach,
  sort_by = 'case_sensitive',
  git = {
    --enable = false,
  },
  sort = {
    sorter = 'name',
  },
  view = {
    width = 31,
    signcolumn = 'auto',
    float = {
      enable = true,
      open_win_config = function()
        local screen_w = vim.opt.columns:get()
        local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
        local window_w = screen_w * 0.5
        local window_h = screen_h * 0.8
        local window_w_int = math.floor(window_w)
        local window_h_int = math.floor(window_h)
        local center_x = (screen_w - window_w) / 2
        local center_y = ((vim.opt.lines:get() - window_h) / 2) - vim.opt.cmdheight:get()
        return {
          border = 'single',
          relative = 'editor',
          row = center_y,
          col = center_x,
          width = window_w_int,
          height = window_h_int,
          title = ' NvimTree ',
          title_pos = 'center',
        }
      end,
    },
  },
  renderer = {
    group_empty = true,
    icons = {
      git_placement = 'right_align',
      glyphs = {
        git = {
          untracked = '',
          --ignored = vim.env.TERM_PROGRAM ~= 'kitty' and '' or nil,
        },
      },
    },
  },
  filters = {
    dotfiles = true,
    git_ignored = false,
  },
  trash = {
    cmd = 'trash',
  },
  actions = {
    open_file = {
      resize_window = false,
      window_picker = {
        enable = true,
        picker = vim.fn['myrc#GetWindowIdForNvimTreeToOpen'],
      },
    },
    change_dir = {
      enable = false,
    },
  },
  filesystem_watchers = {
    enable = false, -- 开启的话, 在大目录退出 nvim 的时候会卡一下
  },

  -- 试验性的功能
  experimental = {
    actions = {
      open_file = {
        relative_path = true,
      },
    },
  },
}

if require('utils').only_ascii() then
  nvim_tree_opts.renderer.icons = vim.tbl_deep_extend('force', nvim_tree_opts.renderer.icons, {
    symlink_arrow = ' -> ',
    show = {
      file = false,
      folder = false,
    },
    glyphs = {
      symlink = '',
      folder = {
        arrow_closed = '+',
        arrow_open = '~',
      },
    },
  })
end

-- 每个窗口记录上一个窗口, 以实现保存窗口跳转历史
vim.api.nvim_create_autocmd('WinEnter', {
  callback = function()
    vim.api.nvim_win_set_var(0, 'prev_winid', vim.fn.win_getid(vim.fn.winnr('#')))
  end,
})

require('nvim-tree').setup(nvim_tree_opts)
