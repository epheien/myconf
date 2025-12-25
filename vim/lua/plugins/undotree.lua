return {
  'XXiaoA/atone.nvim',
  cmd = { 'Atone', 'Undotree' },
  config = function()
    vim.api.nvim_create_user_command(
      'Undotree',
      function(opts) vim.cmd('Atone ' .. opts.args) end,
      {
        nargs = '*',
        complete = function(arg_lead, _cmd_line, _cursor_pos)
          -- 获取原命令的补全
          return vim.fn.getcompletion('Atone ' .. arg_lead, 'cmdline')
        end,
      }
    )
    local opts = {
      ui = {
        compact = true,
      },
    }
    require('atone').setup(opts)
  end,
}
