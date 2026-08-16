local function init()
  local use_snack_image = true
  local plugins = {}
  if vim.fn.has('gui_running') == 1 then
    return {}
  end

  if use_snack_image then
    table.insert(plugins, {
      'epheien/snacks-image.nvim',
      ft = { 'markdown' },
      dependencies = {
        'epheien/snacks-base.nvim',
      },
      opts = {
        image = {
          doc = {
            hide_in_insert = true,
          },
          convert = {
            mermaid_backend = 'merman',
          },
        },
      },
    })
  else
    table.insert(plugins, {
      '3rd/image.nvim',
      cmd = 'ImageRender',
      event = { 'BufReadPre', 'InsertEnter' },
      config = function()
        require('image').setup({
          processor = 'magick_cli',
          max_height_window_percentage = 100,
          editor_only_render_when_focused = true,
          tmux_show_only_in_active_window = true,
          integrations = {
            markdown = {
              enabled = true,
              clear_in_insert_mode = false,
              -- 禁用以避免卡顿/卡死
              download_remote_images = false,
              only_render_image_at_cursor = false,
              -- if true, images will be rendered in floating markdown windows
              floating_windows = true,
              filetypes = { 'markdown', 'vimwiki' },
            },
          },
        })
        vim.api.nvim_create_user_command('ImageRender', function() end, {})
      end,
    })
  end
  return plugins
end

return init()
