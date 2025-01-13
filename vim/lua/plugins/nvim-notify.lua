do return {} end

return {
  'rcarriga/nvim-notify',
  enabled = vim.g.enable_noice,
  event = 'VeryLazy',
  config = function()
    local minimum_width = 20
    require('notify').setup({
      render = 'wrapped-compact',
      minimum_width = 20,
      -- NOTE: 必需确保 max_width >= minimum_width, 否则会出现奇怪的问题
      max_width = function() return math.max(vim.o.columns, minimum_width) end,
      animate = false,
      --stages = 'no_animation',
      stages = require('plugins.config.nvim-notify').stages(
        require('notify.stages.util').DIRECTION.TOP_DOWN
      ),
      icons = {
        ERROR = ' ',
        WARN = ' ',
        INFO = ' ',
        DEBUG = ' ',
        TRACE = ' ',
      },
      on_open = function(win)
        vim.api.nvim_set_option_value('winblend', 10, { win = win })
        vim.api.nvim_win_set_config(win, { zindex = 400, border = 'single' })
      end,
    })
    vim.notify = function(msg, level, opts) ---@diagnostic disable-line
      opts = opts or {}
      --opts.keep = function() return false end
      --opts.timeout = 1000
      require('notify')(msg, level, opts)
    end
  end,
}
