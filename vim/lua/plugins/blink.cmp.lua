return {
  'saghen/blink.cmp',
  enabled = false,
  version = '*',
  dependencies = { 'rafamadriz/friendly-snippets', 'epheien/nvim-cmp' },
  cmd = 'BlinkEnable',
  --keys = { ':', '/', '?' },
  config = function()
    require('plugins.config.blink-cmp')
    -- 启用 blink.cmp 的话就禁用掉 nvim-cmp 的编辑文本补全
    --vim.cmd('silent! CmpDisable')
  end,
}
