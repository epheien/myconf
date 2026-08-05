return {
  'epheien/sidekick.nvim',
  cmd = { 'Sidekick' },
  opts = {
    -- add any options here
    cli = {
      mux = {
        backend = 'tmux',
        enabled = false,
      },
      win = {
        config = function(terminal)
          -- 动态调整 split 宽度
          terminal.opts.split.width = math.floor(vim.o.columns * 0.4)
        end,
        -- stylua: ignore
        keys = {
          buffers       = false,
          files         = false,
          hide_n        = false,
          hide_ctrl_q   = false,
          hide_ctrl_dot = false,
          hide_ctrl_z   = false,
          prompt        = false,
          stopinsert    = false,
          normal_cr     = false,
          nav_left      = false,
          nav_down      = false,
          nav_up        = false,
          nav_right     = false,
        },
      },
      tools = {
        omp = {
          cmd = { 'omp' },
        },
      },
      prompts = {
        commit = '把当前添加到git暂存的修改提交，撰写合适的提交信息，其他文件不要管。@',
      },
    },
  },
  config = function(_plug, opts)
    vim.api.nvim_set_hl(0, 'SidekickChat', { link = 'Normal' })
    require('sidekick').setup(opts)

    vim.keymap.set({ 'n', 'x' }, '<C-x>', function()
      require('sidekick.cli').prompt({
        cb = function(msg, _text)
          if not msg then
            return
          end
          local submit = msg:sub(-1) == '@'
          if submit then
            msg = msg:sub(1, -2)
          end
          require('sidekick.cli').send({ msg = msg, focus = false, submit = submit })
        end,
      })
    end, { silent = true, remap = false })
  end,
  keys = {
    {
      '<leader>at',
      function() require('sidekick.cli').send({ msg = '{this}' }) end,
      mode = { 'x', 'n' },
      desc = 'Send This',
    },
    {
      '<leader>af',
      function() require('sidekick.cli').send({ msg = '{file}' }) end,
      desc = 'Send File',
    },
    {
      '<leader>av',
      function() require('sidekick.cli').send({ msg = '{selection}' }) end,
      mode = { 'x' },
      desc = 'Send Visual Selection',
    },
  },
}
