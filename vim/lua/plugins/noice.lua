---@diagnostic disable-next-line
local function setup_noice() -- {{{
  require('noice').setup({
    --override = {
    --  ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
    --  ['vim.lsp.util.stylize_markdown'] = true,
    --  ['cmp.entry.get_documentation'] = true, -- requires hrsh7th/nvim-cmp
    --},
    presets = {
      bottom_search = true, -- use a classic bottom cmdline for search
      command_palette = true, -- position the cmdline and popupmenu together
      long_message_to_split = true, -- long messages will be sent to a split
      --inc_rename = false, -- enables an input dialog for inc-rename.nvim
      --lsp_doc_border = false, -- add a border to hover docs and signature help
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
      enabled = true,
    },
    -- lua/noice/config/views.lua
    views = {
      cmdline_popup = {
        border = {
          style = 'single',
        },
      },
      mini = {
        timeout = 5000,
        position = {
          row = 1,
          col = -1,
        },
      },
    },
    cmdline = {
      enabled = true,
      format = {
        help = false,
        lua = false,
        filter = false,
        cmdline = {
          title = '',
          icon = ':',
        },
        --search_down = { icon = "/ ⌄" },
        --search_up = { icon = "? ⌃" },
      },
      opts = {},
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
  vim.api.nvim_set_hl(0, 'NoiceCmdlinePopupBorder', { link = 'FloatBorder' })
  vim.api.nvim_set_hl(0, 'NoiceLspProgressTitle', { link = 'Comment' })
end
-- }}}

local enabled = vim.fn.has('nvim-0.10') == 1 and true

return {
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    dependencies = { 'MunifTanjim/nui.nvim', 'rcarriga/nvim-notify' },
    config = setup_noice,
    enabled = enabled,
  },
  -- 替代 fidget.nvim 的 LSP 进度
  { 'j-hui/fidget.nvim', enabled = not enabled },
  { 'echasnovski/mini.notify', enabled = not enabled },
}
