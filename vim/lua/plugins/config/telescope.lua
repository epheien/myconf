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
      -- stylua: ignore
      vim.keymap.set('n', '<Tab>', function()
        vim.cmd(string.format('noautocmd lua vim.api.nvim_set_current_win(%s)', prompt_win))
      end, { buffer = preview_bufnr })
    end
    -- results_win => preview_win
    -- stylua: ignore
    vim.keymap.set('n', '<Tab>', function()
      vim.cmd(
        string.format('noautocmd lua vim.api.nvim_set_current_win(%s)', preview_win or prompt_win)
      )
    end, { buffer = picker.results_bufnr })
    -- prompt_win => results_win
    vim.cmd(string.format('noautocmd lua vim.api.nvim_set_current_win(%s)', results_win))
  end
  local actions = require('telescope.actions')
  local opts = {
    -- Default configuration for telescope goes here:
    -- config_key = value,
    mappings = {
      i = {
        ['<Esc>'] = actions.close,
        ['<C-j>'] = actions.move_selection_next,
        ['<C-k>'] = actions.move_selection_previous,
        ['<C-l>'] = false,
        ['<C-u>'] = false,
        ['<C-b>'] = actions.preview_scrolling_up,
        ['<C-f>'] = actions.preview_scrolling_down,
        ['<Tab>'] = toggle_focus,
        ['<S-Tab>'] = actions.toggle_selection + actions.move_selection_worse,
      },
    },
    sorting_strategy = 'ascending',
    layout_config = {
      prompt_position = 'top',
    },
    -- border = 'single'
    borderchars = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
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
  -- telescope 的 undo 插件
  require('telescope').load_extension('undo')
  -- telescope 的 gtags 插件, 但是貌似不能正常工作, 待完善
  require('telescope').load_extension('gtags')
end

setup_telescope()
