local function init()
  local plugins = {}
  -- NOTE: 打开 markdown 的时候可能导致卡死, 例如 glrnvim 的 README.md
  -- NOTE: tmux 环境下使用 image.nvim 问题多多, 主要是不能自动消失, 所以暂时禁用
  if vim.fn.has('gui_running') ~= 1 then
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
