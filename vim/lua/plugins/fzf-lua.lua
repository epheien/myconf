return {
  'ibhagwan/fzf-lua',
  cmd = 'FzfLua',
  -- optional for icon support
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  -- or if using mini.icons/mini.nvim
  -- dependencies = { "echasnovski/mini.icons" },
  config = function()
    local opts = {
      hls = {
        border = 'FloatBorder',
        preview_border = 'FloatBorder',
      },
      winopts = {
        border = 'single',
        preview = {
          border = 'single',
          horizontal = 'right:45%',
        },
        on_create = function()
          -- called once upon creation of the fzf main window
          -- can be used to add custom fzf-lua mappings, e.g:
          local opts = { silent = true, buffer = true }
          vim.keymap.set('t', '<C-j>', '<Down>', opts)
          vim.keymap.set('t', '<C-k>', '<Up>', opts)
          vim.keymap.set('n', 'q', [[<C-w>q]], opts)
          vim.keymap.set('n', '<Tab>', 'i', opts)
          vim.keymap.set('t', '<Tab>', function()
            vim.cmd.stopinsert()
            vim.schedule(function()
              local lnum = vim.api.nvim_win_get_cursor(0)[1]
              if lnum == 1 then
                vim.fn.search([[^\S\s\+]], 'w')
                vim.cmd([[normal! w]])
              end
            end)
          end, opts)
        end,
      },
      files = {
        git_icons = false, -- 避免搜索文件前执行 git 操作影响性能
      },
    }
    require('fzf-lua').setup(opts)
  end,
}
