---@diagnostic disable-next-line
local function setup_noice() -- {{{
  require('noice').setup({
    override = {
      ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
      ['vim.lsp.util.stylize_markdown'] = true,
      ['cmp.entry.get_documentation'] = true, -- requires hrsh7th/nvim-cmp
    },
    presets = {
      bottom_search = true, -- use a classic bottom cmdline for search
      command_palette = true, -- position the cmdline and popupmenu together
      long_message_to_split = true, -- long messages will be sent to a split
      inc_rename = false, -- enables an input dialog for inc-rename.nvim
      lsp_doc_border = false, -- add a border to hover docs and signature help
    },
    lsp = {
      signature = {
        enabled = false,
      },
    },
    popupmenu = {
      enabled = false,
    },
    notify = {
      enabled = false,
    },
    views = {
      align = 'message-left',
      position = {
        col = 0,
      },
      popup = {
        border = {
          style = 'none',
        },
      },
    },
    cmdline_popup = {
      position = {
        row = 5,
        col = '00%',
      },
      size = {
        width = 60,
        height = 'auto',
      },
    },
    cmdline = {
      enabled = true,
      format = {
        help = false,
        lua = false,
        filter = false,
        --search_down = { icon = "/ ⌄" },
        --search_up = { icon = "? ⌃" },
      },
    },
    messages = {
      enabled = true, -- false 会使用 cmdline, 可避免闪烁
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
          error = '✖',
          warn = '▼',
          info = '●',
        },
      },
    },
  })
end
-- }}}

return {
  'folke/noice.nvim',
  dependencies = { 'MunifTanjim/nui.nvim', 'rcarriga/nvim-notify' },
  config = setup_noice,
  enabled = vim.fn.has('nvim-0.10') == 1 and false,
}
