local M = {}

local enabled = false

local opts = {
  enabled = function() return enabled end,
  fuzzy = { implementation = 'lua' }, -- 为了简化, 仅使用 lua 实现
  keymap = {
    preset = 'none', ---@diagnostic disable-line
    -- 最基本要求
    ['<C-e>'] = { 'cancel', 'fallback' },
    ['<CR>'] = { 'select_and_accept', 'fallback' },
    ['<C-k>'] = { 'select_prev', 'fallback' },
    ['<C-j>'] = { 'select_next', 'fallback' },
    ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
    ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
    -- 添头
    ['<C-y>'] = { 'select_and_accept', 'fallback' },
    ['<C-p>'] = { 'select_prev', 'fallback' },
    ['<C-n>'] = { 'select_next', 'fallback' },
    ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
    ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
  },
  cmdline = {
    enabled = true,
    completion = {
      menu = {
        auto_show = function() return true end,
      },
      list = {
        selection = {
          auto_insert = false,
          preselect = false,
        },
      },
    },
    keymap = {
      preset = 'none',
      ['<C-e>'] = { 'cancel', 'fallback' },
      --['<CR>'] = { 'select_and_accept', 'fallback' },
      ['<C-k>'] = { 'insert_prev', 'fallback' },
      ['<C-j>'] = { 'insert_next', 'fallback' },
      ['<Tab>'] = { 'show', 'insert_next' },
      ['<S-Tab>'] = { 'show', 'insert_prev' },
    },
    sources = { 'buffer', 'cmdline' },
  },
  completion = {
    list = {
      selection = {
        auto_insert = false,
      },
    },
  },
}

require('blink.cmp').setup(opts)

vim.api.nvim_create_user_command('BlinkEnable', function() enabled = true end, {})
vim.api.nvim_create_user_command('BlinkDisable', function() enabled = false end, {})

return M
