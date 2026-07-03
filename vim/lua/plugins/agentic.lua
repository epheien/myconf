-- TODO: 每次启动都新建新会话, 导致了很多冗余的新会话, 这不是好用的方式

return {
  'carlos-algms/agentic.nvim',

  --- @type agentic.PartialUserConfig
  opts = {
    -- Any ACP-compatible provider works. Built-in: "claude-agent-acp" | "gemini-acp" | "codex-acp" | "opencode-acp" | "cursor-acp" | "copilot-acp" | "auggie-acp" | "mistral-vibe-acp" | "cline-acp" | "goose-acp" | "kiro-acp" | "pi-acp"
    provider = 'opencode-acp', -- setting the name here is all you need to get started
    winbar = {},
  },

  cmd = 'Agentic',

  config = function(_plug, opts)
    require('agentic').setup(opts)
    local subcommands = {
      toggle = function() require('agentic').toggle() end,
      add_selection = function() require('agentic').add_selection_or_file_to_context() end,
      new_session = function() require('agentic').new_session() end,
      restore_session = function() require('agentic').restore_session() end,
      add_line_diag = function() require('agentic').add_current_line_diagnostics() end,
      add_buffer_diag = function() require('agentic').add_buffer_diagnostics() end,
    }
    vim.api.nvim_create_user_command('Agentic', function(input)
      local f = subcommands[input.args]
      if f then
        f()
      else
        local names = vim.tbl_keys(subcommands)
        table.sort(names)
        vim.ui.select(names, { prompt = 'Agentic: ' }, function(name)
          if name then
            subcommands[name]()
          end
        end)
      end
    end, {
      nargs = '?',
      complete = function(_, _)
        local names = vim.tbl_keys(subcommands)
        table.sort(names)
        return names
      end,
    })

    local function set_minimal_statusline(win)
      vim.wo[win][0].statusline = '─'
      vim.wo[win][0].fillchars = vim.wo[win].fillchars .. ',stl:─,stlnc:─'
    end

    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'Agentic*',
      callback = function(args)
        local bufnr = args.buf
        local count = 0
        local augroup = vim.api.nvim_create_augroup('AgenticOpts_' .. bufnr, { clear = true })

        if args.match == 'AgenticInput' then
          local input_augroup =
            vim.api.nvim_create_augroup('AgenticInputOpts_' .. bufnr, { clear = true })
          vim.api.nvim_create_autocmd('WinEnter', {
            group = input_augroup,
            buffer = bufnr,
            callback = vim.schedule_wrap(function()
              vim.cmd('normal! G$')
              vim.cmd('startinsert!')
            end),
          })
          vim.api.nvim_create_autocmd('WinLeave', {
            group = input_augroup,
            buffer = bufnr,
            callback = function() vim.cmd('stopinsert') end,
          })
        end

        vim.api.nvim_create_autocmd('OptionSet', {
          group = augroup,
          pattern = 'winbar',
          callback = function(_event)
            if count >= 10 then
              pcall(vim.api.nvim_del_augroup_by_id, augroup)
              return
            end
            count = count + 1
            local winid = vim.fn.bufwinid(bufnr)
            if not winid or winid == 0 or not vim.api.nvim_win_is_valid(winid) then
              return
            end

            if not vim.v.option_new or not vim.v.option_new:find('Agentic') then
              return
            end
            set_minimal_statusline(winid)
            count = 10

            pcall(vim.api.nvim_del_augroup_by_id, augroup)
          end,
        })
      end,
    })
  end,
}
