local M = {}

function M.avante_input_statusline()
  local sidebar = require('avante').get()
  local fun = function()
    if not sidebar:is_open() then
      return -1
    end
    return sidebar:get_tokens_usage()
  end
  local ok, tokens = pcall(fun)
  if not ok or tokens < 0 then
    return ''
  end
  local api = vim.api
  local content = ' Tokens: ' .. math.floor(tokens / 1000) .. ',' .. (tokens % 1000) .. ' '
  local padding = math.floor(
    (api.nvim_win_get_width(sidebar.containers.input.winid) - api.nvim_strwidth(content)) / 2
  )
  local padding_text = string.rep('─', padding)
  return padding_text .. '%#AvanteThirdTitle#' .. content .. '%#StatusLine#'
end

local opts = {
  -- add any opts here
  -- this file can contain specific instructions for your project
  instructions_file = 'avante.md',
  -- add any opts here
  system_prompt = '**Important**: Both thinking and answering must be in Chinese and write the file content in Chinese.\n',
  provider = 'vllm',
  providers = {
    vllm = {
      __inherited_from = 'openai',
      api_key_name = '',
      endpoint = 'http://192.168.3.244:8000/v1',
      model = 'glm-4.7',
      model_names = { 'minimax-m2.1', 'glm-4.7' },
      context_window = 192 * 1024,
      extra_request_body = {
        temperature = 1.0,
        max_tokens = 32768,
        top_p = 0.95,
        top_k = 40,
      },
    },
    ['vllm-docker'] = {
      __inherited_from = 'openai',
      api_key_name = '',
      endpoint = 'http://192.168.3.244:8800/v1',
      model = 'minimax-m2.1',
      context_window = 192 * 1024,
      extra_request_body = {
        temperature = 1.0,
        max_tokens = 32768,
        top_p = 0.95,
        top_k = 40,
      },
    },
  },
  --disabled_tools = { 'fetch' },
  behaviour = {
    --auto_focus_sidebar = false,
    --auto_approve_tool_permissions = { 'view', 'grep' },
    auto_approve_tool_permissions = false,
    confirmation_ui_style = 'popup', -- default: inline_buttons; inline_buttons 超多 BUG
    auto_add_current_file = false,
    --eager_update = true,
    incremental_render = true,
  },
  windows = {
    position = 'left',
    fillchars = 'eob: ,stl:─,stlnc:─',
    ask = {
      border = 'single',
    },
    spinner = {
      generating = { '·', '✢', '✳', '·', '✢', '✳' },
    },
    input = {
      height = 2, -- 需要修复 avante 的布局调整的 bug 才能正常工作
    },
    input_hint = {
      enabled = false,
    },
    sidebar_header = {
      enabled = false,
    },
  },
  slash_commands = {
    {
      name = 'commit',
      description = 'Commit the changes',
      callback = function(sidebar, _args, cb) -- NOTE: _args 恒为 nil
        sidebar:update_content('执行结果', { focus = false, scroll = false })
        local request =
          '把当前添加到git暂存的修改提交，撰写合适的提交信息，其他文件不要管。'
        vim.api.nvim_exec_autocmds(
          'User',
          { pattern = 'AvanteInputSubmitted', data = { request = request } }
        )
        cb()
      end,
    },
  },
}

local api = vim.api
vim.api.nvim_set_hl(0, 'AvanteSidebarWinSeparator', { link = 'WinSeparator' })
vim.api.nvim_set_hl(0, 'AvanteSidebarWinHorizontalSeparator', { link = 'WinSeparator' })
vim.api.nvim_set_hl(0, 'AvanteSidebarNormal', { link = 'Normal' })
vim.api.nvim_set_hl(0, 'AvantePromptInputBorder', { link = 'FloatBorder' })
vim.api.nvim_set_hl(0, 'AvanteReversedThirdTitle', { fg = '#353B45' })
--vim.api.nvim_set_hl(0, 'AvanteButtonDefault', { link = 'PmenuThumb' })
-- 需要自己主动启用 Avante 文件类型的 treesitter 语法高亮
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'Avante' },
  callback = function()
    vim.treesitter.start()
    local winid = api.nvim_get_current_win()
    api.nvim_set_option_value('cc', '', { win = winid })
    api.nvim_set_option_value('winfixheight', false, { win = winid })
    api.nvim_set_option_value('statusline', '─', { win = winid })
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'AvanteInput',
  callback = function(ev)
    vim.api.nvim_set_option_value('cc', '', { win = vim.api.nvim_get_current_win() })
    vim.cmd('inoremap <silent> <buffer> <C-h> <Esc><C-w>h')
    --vim.cmd('inoremap <silent> <buffer> <C-j> <Esc><C-w>j')
    --vim.cmd('inoremap <silent> <buffer> <C-k> <Esc><C-w>k')
    vim.cmd('inoremap <silent> <buffer> <C-l> <Esc><C-w>l')
    vim.keymap.set('i', '<C-j>', function()
      local ok, val = pcall(function() return require('cmp').core.view:visible() end)
      if ok and val then
        vim.cmd([[call feedkeys("\<Down>")]])
      else
        vim.cmd([[call feedkeys("\<Esc>\<C-w>j")]])
      end
    end, { buffer = ev.buf })
    vim.keymap.set('i', '<C-k>', function()
      local ok, val = pcall(function() return require('cmp').core.view:visible() end)
      if ok and val then
        vim.cmd([[call feedkeys("\<Up>")]])
      else
        vim.cmd([[call feedkeys("\<Esc>\<C-w>k")]])
      end
    end, { buffer = ev.buf })
  end,
})
vim.cmd([[command! AvanteToggleDebug lua require('avante').toggle.debug()]])

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'AvanteInput' },
  callback = function()
    vim.api.nvim_set_option_value(
      'statusline',
      '%!v:lua.require\'plugins.config.avante\'.avante_input_statusline()',
      {
        win = vim.api.nvim_get_current_win(),
      }
    )
  end,
})

require('avante').setup(opts)

return M
