return {
  'sudo-tee/opencode.nvim',
  cmd = { 'Opencode' },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MeanderingProgrammer/render-markdown.nvim',
    -- Optional, for file mentions and commands completion, pick only one
    -- 'saghen/blink.cmp',
    'hrsh7th/nvim-cmp',

    -- Optional, for file mentions picker, pick only one
    -- 'folke/snacks.nvim',
    'nvim-telescope/telescope.nvim',
    -- 'ibhagwan/fzf-lua',
    -- 'nvim_mini/mini.nvim',
  },
  opts = {
    preferred_picker = 'telescope',
    preferred_completion = 'nvim-cmp',
    keymap = {
      input_window = {
        ['<cr>'] = false,
        ['<C-s>'] = { 'submit_input_prompt', mode = { 'n', 'i' } }, -- Submit prompt (normal mode and insert mode)
        ['<esc>'] = false,
        ['<C-k>'] = {
          function()
            local ok, val = pcall(function() return require('cmp').core.view:visible() end)
            if ok and val then
              vim.cmd([[call feedkeys("\<Up>")]])
            else
              vim.cmd([[call feedkeys("\<Esc>\<C-w>k")]])
            end
          end,
          mode = { 'i' },
        },
        ['<C-j>'] = {
          function()
            local ok, val = pcall(function() return require('cmp').core.view:visible() end)
            if ok and val then
              vim.cmd([[call feedkeys("\<Down>")]])
            else
              vim.cmd([[call feedkeys("\<Esc>\<C-w>j")]])
            end
          end,
          mode = { 'i' },
        },
        ['<up>'] = false,
        ['<down>'] = false,
        ['<C-p>'] = { 'prev_prompt_history', mode = { 'i' } }, -- Navigate to previous prompt in history
        ['<C-n>'] = { 'next_prompt_history', mode = { 'i' } }, -- Navigate to next prompt in history
      },
      output_window = {
        ['<esc>'] = false,
      },
    },
    ui = {
      position = 'current',
      input_height = 0.1,
    },
  },
  config = function(_plug, _opts)
    require('opencode').setup(_opts)
    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'opencode', 'opencode_output' },
      callback = function(_event) vim.b[_event.buf].buf_name = _event.match end,
    })
  end,
}
