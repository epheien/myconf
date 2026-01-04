return {
  'epheien/avante.nvim',
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = 'make',
  cmd = { 'AvanteAsk' },
  lazy = true,
  version = false, -- Never set this value to "*"! Never!
  config = function(_plug, _opts) require('plugins.config.avante') end,
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
