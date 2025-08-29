local fmt = string.format

local constants = {
  LLM_ROLE = 'llm',
  USER_ROLE = 'user',
  SYSTEM_ROLE = 'system',
}

local opts = {
  -- refer to: https://github.com/olimorris/codecompanion.nvim/blob/main/lua/codecompanion/config.lua
  adapters = {
    http = {
      ollama = function()
        return require('codecompanion.adapters').extend('ollama', {
          env = {
            url = 'http://pve:1434',
          },
          schema = {
            model = {
              default = 'qwen3-coder:30b', -- 'deepseek-r1:32b'
            },
          },
          parameters = {
            sync = true,
          },
        })
      end,
      openai_compatible = function()
        return require("codecompanion.adapters").extend("openai_compatible", {
          env = {
            url = 'http://pve:1434',
          },
          schema = {
            model = {
              default = "qwen3-coder:30b",
            },
          },
        })
      end,
    },
  },
  strategies = {
    -- NOTE: Change the adapter as required
    chat = { adapter = 'openai_compatible' },
    inline = { adapter = 'openai_compatible' },
    cmd = { adapter = 'openai_compatible' },
  },
  display = {
    action_palette = {
      provider = 'telescope',
    },
    chat = {
      window = {
        layout = 'horizontal',
        height = 0.5,
      },
    },
  },
  opts = {
    language = "Chinese",
  },
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
    ['Unit Tests'] = {
      prompts = {
        {
          role = constants.SYSTEM_ROLE,
          content = [[When generating unit tests, follow these steps:

1. Identify the programming language.
2. Identify the purpose of the function or module to be tested.
3. List the edge cases and typical use cases that should be covered in the tests and share the plan with the user.
4. Generate unit tests using an appropriate testing framework for the identified programming language.
5. Ensure the tests cover:
      - Normal cases
      - Edge cases
      - Error handling (if applicable)
6. Provide the generated unit tests in a clear and organized manner without additional explanations or chat.]],
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
              [[请为缓冲区 %d 中的此代码生成单元测试:

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
