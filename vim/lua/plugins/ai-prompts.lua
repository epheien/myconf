return {
  'epheien/ai-prompts.nvim',
  lazy = true,
  dependencies = {
    'nvim-telescope/telescope.nvim',
  },
  config = function()
    require('ai-prompts').setup({
      custom_prompts = {
        {
          name = 'commit',
          content = '把当前添加到git暂存的修改提交，撰写合适的提交信息。',
          description = '',
        },
      },
    })
  end,
}
