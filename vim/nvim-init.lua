-- 读取 vimrc
--local vimrc = vim.fn.stdpath("config") .. "/vimrc"
--vim.cmd.source(vimrc)

local ok, mod = pcall(require, 'nvim-tree')
if ok then
  require('config/nvim-tree')
end

local ok, indent_blankline_mod = pcall(require, 'indent_blankline')
if ok then
  indent_blankline_mod.setup({})
end

local ok, telescope_mod = pcall(require, 'telescope')
if ok then
  telescope_mod.setup({
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
  })
end

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
      --enabled = false, -- false 会使用 cmdline, 避免闪烁
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
