---@diagnostic disable-next-line
local function setup_noice() -- {{{
  -- noice 调试专用函数
  function LogToFile(...)
    local file = io.open('temp.txt', 'a')
    if file then
      for i = 1, select('#', ...) do
        local text = select(i, ...)
        if type(text) == 'string' then
          file:write(text .. ' ')
        else
          file:write(vim.inspect(text) .. ' ')
        end
      end
      file:write('\n')
      file:close()
    end
  end

  require('noice').setup({
    --debug = true,
    --override = {
    --  ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
    --  ['vim.lsp.util.stylize_markdown'] = true,
    --  ['cmp.entry.get_documentation'] = true, -- requires hrsh7th/nvim-cmp
    --},
    presets = {
      bottom_search = true, -- use a classic bottom cmdline for search
      command_palette = true, -- position the cmdline and popupmenu together
      --long_message_to_split = true, -- long messages will be sent to a split
      --inc_rename = false, -- enables an input dialog for inc-rename.nvim
      --lsp_doc_border = false, -- add a border to hover docs and signature help
    },
    -- long_message_to_popup
    routes = {
      {
        filter = { event = 'msg_show', min_height = 20 },
        view = 'popup',
      },
    },
    lsp = {
      signature = {
        enabled = false,
      },
      progress = {
        enabled = false,
      },
      hover = {
        enabled = false,
      },
    },
    popupmenu = {
      enabled = false,
    },
    notify = {
      enabled = true,
    },
    -- lua/noice/config/views.lua
    views = {
      cmdline_popup = {
        border = {
          style = 'single',
        },
        position = {
          row = 0.382, -- 0.382 = 1 - 0.618
        },
      },
      mini = {
        timeout = 5000,
        position = {
          row = 1,
          col = -1,
        },
      },
      popup = {
        border = { style = 'single' },
        win_options = {
          winhighlight = { Normal = 'Normal' },
          cursorline = true,
        },
      },
    },
    cmdline = {
      enabled = true,
      format = {
        help = false,
        lua = false,
        filter = false,
        calculator = false,
        --input = false, -- FIXME: 无法设置为 false, 否则报错
        cmdline = {
          title = '',
          icon = '>',
        },
        --search_down = { icon = "/ ⌄" },
        --search_up = { icon = "? ⌃" },
      },
      opts = {},
    },
    messages = {
      enabled = true, -- false 会使用 cmdline, 可避免闪烁
      --view = 'mini',
      --view_error = 'mini',
      --view_warn = 'mini',
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
          error = '✖',
          warn = '▼',
          info = '●',
        },
      },
    },
  })
  vim.api.nvim_set_hl(0, 'NoiceCmdlinePopupBorder', { link = 'FloatBorder' })
  vim.api.nvim_set_hl(0, 'NoiceLspProgressTitle', { link = 'Comment' })
  vim.api.nvim_set_hl(0, 'NoiceSplit', { link = 'Normal' })
end
-- }}}

local enabled = vim.fn.has('nvim-0.10') == 1 and vim.g.enable_noice

return {
  {
    'epheien/noice.nvim',
    event = 'VeryLazy',
    dependencies = { 'MunifTanjim/nui.nvim', 'echasnovski/mini.notify' },
    config = setup_noice,
    enabled = enabled,
  },
  -- mini.notify 无法高亮 :hi 命令的输出, 无法替代 nvim-notify
  { 'mini.notify', enabled = not enabled },
}
