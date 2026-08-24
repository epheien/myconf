return {
  {
    'epheien/render-markdown.nvim',
    ft = { 'markdown', 'Avante', 'codecompanion', 'opencode_output' },
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    opts = {
      -- Whether Markdown should be rendered by default or not
      enabled = true,
      render_modes = { 'n', 'c', 't', 'nt' },
      file_types = { 'markdown', 'Avante', 'codecompanion', 'opencode_output' },
      code = {
        enabled = true,
        sign = false,
      },
      heading = {
        sign = false,
      },
      dash = {
        icon = '━',
      },
      anti_conceal = {
        enabled = false,
      },
      win_options = {
        concealcursor = {
          rendered = 'nc',
        },
      },
      checkbox = {
        custom = {
          partial = {
            raw = '[~]',
            rendered = '󰥔 ',
            highlight = 'RenderMarkdownTodo',
            scope_highlight = nil,
          },
        },
      },
      -- 表格不再渲染, 交给 markdown-table-wrap.nvim 负责
      pipe_table = { enabled = false },
    },
  },
  {
    'tadmccorkle/markdown.nvim',
    ft = { 'markdown', 'Avante', 'codecompanion', 'opencode_output' },
    opts = {
      mappings = {
        link_follow = 'gx',
        -- 释放 ds/cs 给 nvim-surround (markdown 里原本被抢占)
        inline_surround_delete = false,
        inline_surround_change = false,
        -- 释放 ]c (diff 下一个变更)、]p (缩进粘贴)
        go_curr_heading = false,
        go_parent_heading = false,
        -- 释放 ]] / [[ (内置 section 跳转)
        go_next_heading = false,
        go_prev_heading = false,
      },
    },
  },
}
