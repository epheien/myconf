return {
  'yetone/avante.nvim',
  cmd = { 'AvanteChat', 'AvanteAsk' },
  lazy = true,
  version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
  opts = {
    -- add any opts here
    provider = 'ollama',
    vendors = {
      ollama = {
        __inherited_from = 'openai',
        api_key_name = 'OLLAMA_API_KEY', -- export OLLAMA_API_KEY=...
        endpoint = 'http://127.0.0.1:3000/v1',
        model = 'deepseek-r1:7b',
      },
    },
  },
  config = function(plug, opts) ---@diagnostic disable-line
    require('avante').setup(opts)
    -- 需要自己主动启用 Avante 文件类型的 treesitter 语法高亮
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'Avante',
      callback = function() vim.treesitter.start() end,
    })
  end,
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = 'make',
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  dependencies = {
    'stevearc/dressing.nvim',
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    --- The below dependencies are optional,
    'echasnovski/mini.pick', -- for file_selector provider mini.pick
    'nvim-telescope/telescope.nvim', -- for file_selector provider telescope
    'ibhagwan/fzf-lua', -- for file_selector provider fzf
    'nvim-tree/nvim-web-devicons', -- or echasnovski/mini.icons
    --"zbirenbaum/copilot.lua", -- for providers='copilot'
    'MeanderingProgrammer/render-markdown.nvim',
    {
      -- support for image pasting
      'HakonHarnes/img-clip.nvim',
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
  },
}
