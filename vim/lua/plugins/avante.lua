return {
  'epheien/avante.nvim',
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = 'make',
  cmd = { 'AvanteChat', 'AvanteAsk' },
  lazy = true,
  version = false, -- Never set this value to "*"! Never!
  opts = {
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
        model = 'minimax-m2.1',
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
      ask = {
        border = 'single',
      },
      spinner = {
        generating = { '·', '✢', '✳', '·', '✢', '✳' },
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
  },
  config = function(_plug, opts)
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
        vim.api.nvim_set_option_value('cc', '', { win = vim.api.nvim_get_current_win() })
      end,
    })
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'AvanteInput',
      callback = function()
        vim.api.nvim_set_option_value('cc', '', { win = vim.api.nvim_get_current_win() })
        vim.cmd('inoremap <silent> <buffer> <C-h> <Esc><C-w>h')
        --vim.cmd('inoremap <silent> <buffer> <C-j> <Esc><C-w>j')
        --vim.cmd('inoremap <silent> <buffer> <C-k> <Esc><C-w>k')
        vim.cmd('inoremap <silent> <buffer> <C-l> <Esc><C-w>l')
      end,
    })
    vim.cmd([[command! AvanteToggleDebug lua require('avante').toggle.debug()]])

    require('avante').setup(opts)
  end,
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    --- The below dependencies are optional,
    'nvim-mini/mini.pick', -- for file_selector provider mini.pick
    'nvim-telescope/telescope.nvim', -- for file_selector provider telescope
    'hrsh7th/nvim-cmp', -- autocompletion for avante commands and mentions
    'ibhagwan/fzf-lua', -- for file_selector provider fzf
    'stevearc/dressing.nvim', -- for input provider dressing
    'folke/snacks.nvim', -- for input provider snacks
    'nvim-tree/nvim-web-devicons', -- or echasnovski/mini.icons
    'MeanderingProgrammer/render-markdown.nvim', -- 这个插件在其他地方已正确配置
    --'zbirenbaum/copilot.lua', -- for providers='copilot'
    -- 会导致中文输入的时候出现警告
    --{
    --  -- support for image pasting
    --  'HakonHarnes/img-clip.nvim',
    --  opts = {
    --    -- recommended settings
    --    default = {
    --      embed_image_as_base64 = false,
    --      prompt_for_file_name = false,
    --      drag_and_drop = {
    --        insert_mode = true,
    --      },
    --      -- required for Windows users
    --      use_absolute_path = true,
    --    },
    --  },
    --},
  },
}
