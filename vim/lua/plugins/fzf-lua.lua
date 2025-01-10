return {
  'ibhagwan/fzf-lua',
  cmd = 'FzfLua',
  -- optional for icon support
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  -- or if using mini.icons/mini.nvim
  -- dependencies = { "echasnovski/mini.icons" },
  config = function()
    local opts = {
      winopts = {
        border = 'single',
        preview = {
          border = 'single',
          horizontal = 'right:45%',
        },
        on_create = function()
          -- called once upon creation of the fzf main window
          -- can be used to add custom fzf-lua mappings, e.g:
          vim.keymap.set('t', '<C-j>', '<Down>', { silent = true, buffer = true })
          vim.keymap.set('t', '<C-k>', '<Up>', { silent = true, buffer = true })
        end,
      },
    }
    vim.api.nvim_set_hl(0, 'FzfLuaBorder', { link = 'FloatBorder' })
    require('fzf-lua').setup(opts)
  end,
}
