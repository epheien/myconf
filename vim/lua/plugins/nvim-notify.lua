local ns_id = vim.api.nvim_create_namespace('NotifyHistory')

return {
  'epheien/nvim-notify',
  enabled = vim.g.enable_noice,
  event = 'VeryLazy',
  config = function()
    local minimum_width = 20
    vim.api.nvim_set_hl(0, 'NotifyINFOTitle', { link = 'DiagnosticInfo' })
    vim.api.nvim_set_hl(0, 'NotifyINFOIcon', { link = 'DiagnosticInfo' })
    require('notify').setup({
      render = 'wrapped-compact',
      minimum_width = minimum_width,
      -- NOTE: 必须确保 max_width >= minimum_width, 否则会出现奇怪的问题
      -- NOTE: 需要排除掉 border 的宽度 2, 否则会导致显示的内容不全
      max_width = function() return math.max(vim.o.columns, minimum_width) - 2 end,
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
        vim.api.nvim_set_option_value('virtualedit', 'none', { win = win })
        -- window picker 的 zindex 固定为 300
        vim.api.nvim_win_set_config(win, { zindex = 299, border = 'single' })
      end,
    })
    vim.notify = function(msg, level, opts) ---@diagnostic disable-line
      opts = opts or {}
      --opts.keep = function() return false end
      --opts.timeout = 1000
      require('notify')(msg, level, opts)
    end

    vim.api.nvim_create_user_command('NotifyHistory', function()
      require('utils').create_scratch_floatwin('Notify History')
      vim.opt_local.fillchars:append({ eob = ' ' })
      vim.opt_local.cursorline = true
      vim.keymap.set('n', 'q', '<C-w>q', { buffer = true })
      vim.keymap.set('n', 'R', '<Cmd>NotifyHistory<CR>', { buffer = true })
      local history = require('notify').get_history()
      local bufnr = vim.api.nvim_get_current_buf()
      local pos = vim.api.nvim_win_get_cursor(0)
      -- clear buffer
      vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
      require('mylib.buffer').echo_chunks_list_to_buffer(ns_id, bufnr, history)
      vim.api.nvim_win_set_cursor(0, pos)
    end, { desc = 'show nvim-notify history' })
  end,
}
