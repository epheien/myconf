return {
  'rcarriga/nvim-notify',
  event = 'VeryLazy',
  config = function()
    require('notify').setup({
      render = 'wrapped-compact',
      max_width = function() return math.floor(vim.o.columns * 0.382) end,
      animate = false,
      fps = 1, -- XXX: 尝试完全禁用动画
      icons = {
        ERROR = ' ',
        WARN = ' ',
        INFO = ' ',
        DEBUG = ' ',
        TRACE = ' ',
      },
    })
    vim.notify = function(msg, level, opts) ---@diagnostic disable-line
      opts = opts or {}
      --opts.keep = function() return false end
      --opts.timeout = 1000
      require('notify')(msg, level, opts)
    end
  end,
}
