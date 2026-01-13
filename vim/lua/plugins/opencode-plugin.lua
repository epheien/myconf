-- 简易集成, 不涉及渲染
return {
  'epheien/opencode-plugin.nvim',
  name = 'opencode-plugin',
  enabled = not vim.g.enable_opencode_nvim,
  cmd = { 'Opencode' },
  dependencies = {
    -- Recommended for `ask()` and `select()`.
    'epheien/dressing.nvim', -- for input provider dressing
  },
  config = function(_plug, _opts)
    vim.g.loaded_opencode_plugin = 1

    ---@type opencode.Opts
    vim.g.opencode_opts = {
      -- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition".
      provider = {
        enabled = 'terminal',
        terminal = {
          split = 'above',
        },
      },
      prompts = {
        commit = {
          prompt = '把当前添加到git暂存的修改提交，撰写合适的提交信息，其他文件不要管。',
          submit = true,
        },
      },
    }

    -- 在 plugin/opencode.lua 或你的插件加载文件中

    local function setup_commands()
      local opencode = require('opencode')

      -- 定义所有可用的子命令
      local subcommands = {
        'ask',
        'select',
        'prompt',
        'operator',
        'command',
        'toggle',
        'start',
        'stop',
        'statusline',
        'clear-cached-port',
      }

      -- 创建 Opencode 命令
      vim.api.nvim_create_user_command('Opencode', function(opts)
        local args = opts.fargs
        local subcmd = args[1] or 'toggle'

        -- 检查子命令是否存在
        if not vim.tbl_contains(subcommands, subcmd) then
          vim.notify('未知子命令: ' .. subcmd, vim.log.levels.ERROR)
          return
        end

        if subcmd == 'clear-cached-port' then
          return require('opencode.cli.server').clear_cached_port()
        elseif subcmd == 'prompt' then
          return opencode[subcmd](vim.fn.substitute(opts.args, [[^\s*prompt\s]], '', ''))
        end

        -- 获取对应的函数
        local fn = opencode[subcmd]
        if type(fn) ~= 'function' then
          vim.notify(subcmd .. ' 不是一个可调用的函数', vim.log.levels.ERROR)
          return
        end

        -- 移除子命令本身，传递剩余参数
        local fn_args = { unpack(args, 2) }

        -- 调用对应的函数
        fn(unpack(fn_args))
      end, {
        nargs = '*',
        complete = function(arg_lead, cmd_line, cursor_pos)
          local input_text = vim.fn.trim(cmd_line:sub(1, cursor_pos), ' \t', 1)
          -- 解析已输入的内容
          local parts = vim.split(input_text, '%s+')

          -- 如果只有命令名或正在输入第一个参数，补全子命令
          if #parts <= 2 then
            local matches = {}
            for _, subcmd in ipairs(subcommands) do
              if subcmd:find('^' .. vim.pesc(arg_lead)) then
                table.insert(matches, subcmd)
              end
            end
            return matches
          end

          -- 可以在这里为特定子命令添加更多补全逻辑
          return {}
        end,
        desc = 'OpenCode CLI - 调用 opencode.nvim 的各种方法',
      })
    end

    setup_commands()

    -- 支持 @ 补全
    require('plugins.config.cmp-opencode-plugin').setup()
    require('cmp').setup.filetype({ 'DressingInput' }, {
      sources = {
        { name = 'cmp_opencode_plugin' },
      },
    })

    -- Recommended/example keymaps.
    vim.keymap.set(
      { 'n', 'x' },
      '<C-a>',
      function() require('opencode').ask('', { submit = true, clear = true }) end,
      { desc = 'Ask opencode' }
    )

    vim.keymap.set(
      { 'n', 'x' },
      '<C-x>',
      function() require('opencode').select() end,
      { desc = 'Execute opencode action…' }
    )

    vim.keymap.set(
      { 'n', 'x' },
      'go',
      function() return require('opencode').operator('@this ') end,
      { expr = true, desc = 'Add range to opencode' }
    )
    vim.keymap.set(
      'n',
      'goo',
      function() return require('opencode').operator('@this ') .. '_' end,
      { expr = true, desc = 'Add line to opencode' }
    )

    vim.keymap.set(
      'n',
      '<S-C-b>',
      function() require('opencode').command('session.half.page.up') end,
      { desc = 'opencode half page up' }
    )
    vim.keymap.set(
      'n',
      '<S-C-f>',
      function() require('opencode').command('session.half.page.down') end,
      { desc = 'opencode half page down' }
    )
  end,
}
