local function setup_telescope()
  local toggle_focus = function(prompt_bufnr)
    local action_state = require('telescope.actions.state')
    local picker = action_state.get_current_picker(prompt_bufnr)
    local prompt_win = picker.prompt_win
    local results_win = picker.results_win
    local previewer = picker.previewer
    local preview_win = previewer and previewer.state.winid or nil
    local preview_bufnr = previewer and previewer.state.bufnr or nil
    -- preview_win => prompt_win
    if preview_win then
      vim.keymap.set('n', '<Tab>', function()
        vim.cmd(string.format('noautocmd lua vim.api.nvim_set_current_win(%s)', prompt_win))
      end, { buffer = preview_bufnr })
    end
    -- results_win => preview_win
    vim.keymap.set('n', '<Tab>', function()
      vim.cmd(
        string.format('noautocmd lua vim.api.nvim_set_current_win(%s)', preview_win or prompt_win)
      )
    end, { buffer = picker.results_bufnr })
    -- prompt_win => results_win
    vim.cmd(string.format('noautocmd lua vim.api.nvim_set_current_win(%s)', results_win))
  end
  local opts = {
    -- Default configuration for telescope goes here:
    -- config_key = value,
    mappings = {
      i = {
        ['<Esc>'] = require('telescope.actions').close,
        ['<C-j>'] = require('telescope.actions').move_selection_next,
        ['<C-k>'] = require('telescope.actions').move_selection_previous,
        ['<C-l>'] = false,
        ['<C-u>'] = false,
        ['<C-b>'] = require('telescope.actions').preview_scrolling_up,
        ['<C-f>'] = require('telescope.actions').preview_scrolling_down,
        ['<Tab>'] = toggle_focus,
      },
    },
    sorting_strategy = 'ascending',
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
  vim.api.nvim_set_hl(0, 'TelescopeBorder', { link = 'WinSeparator', force = true })
  vim.api.nvim_set_hl(0, 'TelescopeTitle', { link = 'Title', force = true })
  vim.api.nvim_set_hl(0, 'TelescopeSelection', { link = 'CursorLine' })
  -- telescope 的 undo 插件
  require('telescope').load_extension('undo')
end

setup_telescope()
