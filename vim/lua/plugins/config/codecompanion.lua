local fmt = string.format

local constants = {
  LLM_ROLE = 'llm',
  USER_ROLE = 'user',
  SYSTEM_ROLE = 'system',
}

local opts = {
  -- refer to: https://github.com/olimorris/codecompanion.nvim/blob/main/lua/codecompanion/config.lua
  adapters = {
    ollama = function()
      return require('codecompanion.adapters').extend('ollama', {
        env = {
          url = 'http://localhost:11434',
        },
        schema = {
          model = {
            default = 'starcoder2:instruct', -- 'deepseek-r1:32b'
          },
        },
        parameters = {
          sync = true,
        },
      })
    end,
  },
  strategies = {
    -- NOTE: Change the adapter as required
    chat = { adapter = 'ollama' },
    inline = { adapter = 'ollama' },
  },
  display = {
    action_palette = {
      provider = 'telescope',
    },
  },
  opts = {},
  prompt_library = {
    ['Explain'] = {
      strategy = 'chat',
      description = 'Explain how code in a buffer works',
      opts = {
        index = 5,
        is_default = true,
        is_slash_cmd = false,
        modes = { 'v' },
        short_name = 'explain',
        auto_submit = true,
        user_prompt = false,
        stop_context_insertion = true,
      },
      prompts = {
        {
          role = constants.SYSTEM_ROLE,
          content = [[When asked to explain code, follow these steps:

1. Identify the programming language.
2. Describe the purpose of the code and reference core concepts from the programming language.
3. Explain each function or significant block of code, including parameters and return values.
4. Highlight any specific functions or methods used and their roles.
5. Provide context on how the code fits into a larger application if applicable.]],
          opts = {
            visible = false,
          },
        },
        {
          role = constants.USER_ROLE,
          content = function(context)
            local code = require('codecompanion.helpers.actions').get_code(
              context.start_line,
              context.end_line
            )
            return fmt(
              [[请解释缓冲区 %d 中的此代码:

```%s
%s
```
]],
              context.bufnr,
              context.filetype,
              code
            )
          end,
          opts = {
            contains_code = true,
          },
        },
      },
    },
  },
}
-- 只要插件执行了 vim.treesitter.language.register("markdown", "codecompanion") 就可以直接启用
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'codecompanion',
  callback = function() vim.treesitter.start() end,
})
require('codecompanion').setup(opts)
