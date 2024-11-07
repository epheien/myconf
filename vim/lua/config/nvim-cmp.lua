local cmp = require('cmp')
local keymap = require("cmp.utils.keymap")
local feedkeys = require("cmp.utils.feedkeys")

local M = {}

local enabled = true

---@alias Placeholder {n:number, text:string}

---@param snippet string
---@param fn fun(placeholder:Placeholder):string
---@return string
function M.snippet_replace(snippet, fn)
  return snippet:gsub("%$%b{}", function(m)
    local n, name = m:match("^%${(%d+):(.+)}$")
    return n and fn({ n = n, text = name }) or m
  end) or snippet
end

-- This function resolves nested placeholders in a snippet.
---@param snippet string
---@return string
function M.snippet_preview(snippet)
  local ok, parsed = pcall(function()
    return vim.lsp._snippet_grammar.parse(snippet)
  end)
  return ok and tostring(parsed)
      or M.snippet_replace(snippet, function(placeholder)
        return M.snippet_preview(placeholder.text)
      end):gsub("%$0", "")
end

-- This function replaces nested placeholders in a snippet with LSP placeholders.
function M.snippet_fix(snippet)
  local texts = {} ---@type table<number, string>
  return M.snippet_replace(snippet, function(placeholder)
    texts[placeholder.n] = texts[placeholder.n] or M.snippet_preview(placeholder.text)
    return "${" .. placeholder.n .. ":" .. texts[placeholder.n] .. "}"
  end)
end

-- from lazyvim
---@param entry cmp.Entry
function M.auto_brackets(entry)
  local Kind = cmp.lsp.CompletionItemKind
  local item = entry:get_completion_item()
  if vim.tbl_contains({ Kind.Function, Kind.Method }, item.kind) then
    local cursor = vim.api.nvim_win_get_cursor(0)
    local prev_char = vim.api.nvim_buf_get_text(0, cursor[1] - 1, cursor[2], cursor[1] - 1, cursor[2] + 1, {})[1]
    if prev_char ~= "(" and prev_char ~= ")" then
      local keys = vim.api.nvim_replace_termcodes("()<left>", false, false, true)
      vim.api.nvim_feedkeys(keys, "in", true)
    end
  end
end

-- This function adds missing documentation to snippets.
-- The documentation is a preview of the snippet.
---@param window cmp.CustomEntriesView|cmp.NativeEntriesView
function M.add_missing_snippet_docs(window)
  local Kind = cmp.lsp.CompletionItemKind
  local entries = window:get_entries()
  for _, entry in ipairs(entries) do
    if entry:get_kind() == Kind.Snippet then
      local item = entry:get_completion_item()
      if not item.documentation and item.insertText then
        item.documentation = {
          kind = cmp.lsp.MarkupKind.Markdown,
          value = string.format("```%s\n%s\n```", vim.bo.filetype, M.snippet_preview(item.insertText)),
        }
      end
    end
  end
end

function M.visible()
  return cmp.core.view:visible()
end

local keymap_cinkeys = function(expr)
  return string.format(keymap.t("<Cmd>setlocal cinkeys=%s<CR>"), expr and vim.fn.escape(expr, "| \t\\") or "")
end

-- This is a better implementation of `cmp.confirm`:
--  * check if the completion menu is visible without waiting for running sources
--  * create an undo point before confirming
-- This function is both faster and more reliable.
---@param opts? {select: boolean, behavior: cmp.ConfirmBehavior}
function M.confirm(opts)
  opts = vim.tbl_extend("force", {
    select = true,
    behavior = cmp.ConfirmBehavior.Insert,
  }, opts or {})
  return function(fallback)
    if cmp.core.view:visible() or vim.fn.pumvisible() == 1 then
      M.create_undo()
      -- https://github.com/hrsh7th/nvim-cmp/issues/1035 的临时解决方案, 不完美
      feedkeys.call(keymap_cinkeys(), "n")
      local rc = cmp.confirm(opts) -- 返回 true 表示成功, false 表示失败
      feedkeys.call(keymap_cinkeys(vim.bo.cinkeys), "n")
      if rc then
        return
      end
    end
    fallback = fallback or function() end
    return fallback()
  end
end

function M.expand(snippet)
  -- Native sessions don't support nested snippet sessions.
  -- Always use the top-level session.
  -- Otherwise, when on the first placeholder and selecting a new completion,
  -- the nested session will be used instead of the top-level session.
  -- See: https://github.com/LazyVim/LazyVim/issues/3199
  local session = vim.snippet.active() and vim.snippet._session or nil

  local ok, err = pcall(vim.snippet.expand, snippet)
  if not ok then
    local fixed = M.snippet_fix(snippet)
    ok = pcall(vim.snippet.expand, fixed)

    local msg = ok and "Failed to parse snippet,\nbut was able to fix it automatically."
        or ("Failed to parse snippet.\n" .. err)
    print(msg)
    print(snippet)
  end

  -- Restore top-level session when needed
  if session then
    vim.snippet._session = session
  end
end

---@param opts cmp.ConfigSchema | {auto_brackets?: string[]}
function M.setup(opts)
  --for _, source in ipairs(opts.sources) do
  --  source.group_index = source.group_index or 1
  --end

  local parse = require("cmp.utils.snippet").parse
  require("cmp.utils.snippet").parse = function(input)
    local ok, ret = pcall(parse, input)
    if ok then
      return ret
    end
    return M.snippet_preview(input)
  end

  cmp.setup(opts)

  cmp.event:on('confirm_done', function(event)
    if vim.tbl_contains(opts.auto_brackets or {}, vim.bo.filetype) then
      M.auto_brackets(event.entry)
    end
  end)
  cmp.event:on("menu_opened", function(event)
    M.add_missing_snippet_docs(event.window)
  end)
end

M.CREATE_UNDO = vim.api.nvim_replace_termcodes("<c-G>u", true, true, true)
function M.create_undo()
  if vim.api.nvim_get_mode().mode == "i" then
    vim.api.nvim_feedkeys(M.CREATE_UNDO, "n", false)
  end
end

local lspkind = require('lspkind')
local lspkind_opts
lspkind_opts = {
  mode = 'symbol',
  -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
  -- can also be a function to dynamically calculate max width such as
  -- maxwidth = function() return math.floor(0.45 * vim.o.columns) end,
  maxwidth = 40,
  -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
  ellipsis_char = '...',
  -- show labelDetails in menu. Disabled by default
  show_labelDetails = true,

  -- The function below will be called before any actual modifications from lspkind
  -- so that you can provide more controls on popup customization.
  -- (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
  before = function(entry, vim_item)
    lspkind_opts.maxwidth = vim.fn.mode() == 'i' and 40 or nil
    if entry.source.name == 'nvim_lsp' and string.sub(vim_item.abbr, 1, 1) == ' ' then
      vim_item.abbr = string.gsub(vim_item.abbr, '^%s+', '')
    end
    --if vim_item.word == 'fread' then
    --  print(vim.inspect(vim.tbl_keys(entry)))
    --  vim.fn.writefile(vim.fn.split(vim.json.encode(entry), '\n'), 'a.log')
    --  print(vim.inspect(vim_item))
    --end
    if not vim_item.menu then
      vim_item.menu = string.format('[%s]', entry.source.name) -- menu 显示源名称
    end
    return vim_item
  end
}
local opts = {
  enabled = function()
    local disabled = false
    disabled = disabled or (vim.api.nvim_get_option_value('buftype', { buf = 0 }) == 'prompt')
    disabled = disabled or (vim.fn.reg_recording() ~= '')
    disabled = disabled or (vim.fn.reg_executing() ~= '')
    return not disabled and enabled
  end,
  -- 需要自动补全函数扩展的文件类型
  auto_brackets = { 'python', 'lua', 'c', 'cpp' },
  preselect = cmp.PreselectMode.None,
  window = {
    completion = {
      -- 影响了 cmdline 补全的宽度, 未想到好的解决办法, 暂时关掉
      --maxwidth = 60, -- Linux 系统下, 函数参数列表放到了 menu 项
    },
  },
  formatting = {
    format = lspkind.cmp_format(lspkind_opts)
  },
  completion = {
    completeopt = 'menuone,noinsert',
    -- NOTE: 长度 > 1 可有效避免有些时候无法补全的问题
    -- 例如 f<补全>, 后续打字都是 f 触发的补全, 可能导致无法补全 fread
    -- 设为 2 可有效避免这种问题, 但不彻底 (coc.nvim 也有类似的问题)
    keyword_length = 2,
  },
  experimental = {
    --ghost_text = 'Comment', -- 在文本中间补全的时候会造成文本晃动, 关掉
  },
  matcher = {
    name = 'fzy',
  },
  matching = {
    --disallow_partial_fuzzy_matching = false, -- default: true
    --disallow_symbol_nonprefix_matching = false, -- default: true
  },
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
      --vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      --M.expand(args.body)
    end,
  },
  mapping = {
    -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    --['<CR>'] = M.confirm({ select = true }), -- 由 myrc#SmartEnter() 接管了
    ['<C-b>'] = cmp.mapping.scroll_docs(-3),
    ['<C-f>'] = cmp.mapping.scroll_docs(3),
  },
  -- NOTE: 同一个 source 不能出现在不同分组, 会重名, 导致 group_index 值错误
  sources = cmp.config.sources({
    {
      name = 'nvim_lsp',
      -- lsp setup 的时候传入 capabilities 参数即可正常使用 lsp 的 snippets
      --entry_filter = function (entry, ctx)
      --  -- ignore lsp snippets
      --  if entry:get_kind() == 15 then
      --    return false
      --  end
      --  return true
      --end,
      keyword_length = 2, -- 可单独兜底设置
    },
    {
      name = 'buffer',
      option = {
        get_bufnrs = function()
          local bufs = {}
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            local buf = vim.api.nvim_win_get_buf(win)
            local byte_size = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
            if byte_size <= 1024 * 1024 then -- 1 MiB max
              table.insert(bufs, buf)
            end
          end
          return bufs
        end
      },
    },
    { name = 'path' },
    { name = 'luasnip' },
    --{ name = 'vsnip' },
    --{ name = 'snippets' },
  }),
}

vim.api.nvim_set_keymap('i', '<CR>', '', {
  callback = vim.fn['myrc#SmartEnter'],
  noremap = true,
  silent = true,
})

vim.keymap.set('i', '<Down>', '', {
  callback = function()
    if cmp.visible() then
      cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
    elseif vim.fn.exists(':CocRestart') == 2 and vim.fn['coc#pum#visible'] ~= 0 then
      vim.fn['coc#pum#_navigate'](1, 0)
    else
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Down>', true, true, true), 'in', false)
    end
  end,
  noremap = true,
  silent = true,
  --expr = true,
})

vim.keymap.set('i', '<Up>', '', {
  callback = function()
    if cmp.visible() then
      cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
    elseif vim.fn.exists(':CocRestart') == 2 and vim.fn['coc#pum#visible'] ~= 0 then
      vim.fn['coc#pum#_navigate'](0, 0)
    else
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Up>', true, true, true), 'in', false)
    end
  end,
  noremap = true,
  silent = true,
  --expr = true,
})

vim.keymap.set('i', '<C-e>', '', {
  callback = function()
    if vim.fn.pumvisible() ~= 0 then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-e>', true, true, true), 'n', false)
    elseif cmp.visible() then -- NOTE: cmp.visible() 包含了 pumvisible()
      cmp.abort()
    elseif vim.fn.exists(':CocRestart') == 2 and vim.fn['coc#pum#visible'] ~= 0 then
      vim.fn['coc#pum#close']('cancel')
    else
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<End>', true, true, true), 'in', false)
    end
  end,
  noremap = true,
  silent = true,
  --expr = true,
})

-- load friendly-snippets
require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath('config') .. '/snippets' } })

vim.api.nvim_set_hl(0, 'CmpItemAbbrMatch', { link = 'SpecialChar' })
vim.api.nvim_set_hl(0, 'CmpItemAbbrMatchFuzzy', { link = 'SpecialChar' })
vim.api.nvim_set_hl(0, 'CmpItemMenu', { link = 'String' })
vim.api.nvim_set_hl(0, 'CmpItemKind', { link = 'Identifier' })

vim.keymap.set('s', '<Tab>', function() require('luasnip').jump(1) end, { silent = true })
vim.keymap.set('s', '<S-Tab>', function() require('luasnip').jump(-1) end, { silent = true })

-- nvim-cmp setup
M.setup(opts)

local cmdline_opts = {
  enabled = true,
  window = {
    completion = {
      border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
      winhighlight = 'NormalFloat:Normal,CursorLine:PmenuSel,Search:None',
    },
  },
  completion = {
    completeopt = 'menuone,noinsert,noselect',
    keyword_length = 1,
  },
  mapping = cmp.mapping.preset.cmdline({
    ['<C-n>'] = cmp.config.disable,
    ['<C-p>'] = cmp.config.disable,
    ['<C-j>'] = {
      c = function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        else
          fallback()
        end
      end,
    },
    ['<C-k>'] = {
      c = function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end,
    },
  }),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  }),
  matcher = {
    name = 'fzy',
  },
  matching = {
    -- NOTE: 需要全部关闭才能保证进入真正的 fuzzy match 流程
    -- TODO: 作为一个可选的临时可用性解决方案, 最终方案是换 fuzzy matcher 算法
    disallow_partial_fuzzy_matching = false,    -- default: true
    -- input = '-cmp', word = 'nvim-cmp', 此选项为 true 时, 无法匹配, 否则可匹配
    disallow_symbol_nonprefix_matching = false, -- default: true
  }
}
-- `:` cmdline setup.
cmp.setup.cmdline(':', cmdline_opts)

local search_buffer_source = {
  name = 'buffer',
  option = {
    get_bufnrs = function()
      local buf = vim.api.nvim_get_current_buf()
      local byte_size = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
      if byte_size > 1024 * 1024 then -- 1 MiB max
        return {}
      end
      return { buf }
    end
  },
}

cmp.setup.cmdline('/', vim.tbl_deep_extend('force', cmdline_opts, {
  matcher = {
    name = 'fzy',
  },
  sources = {
    search_buffer_source,
  },
}))

cmp.setup.cmdline('?', vim.tbl_deep_extend('force', cmdline_opts, {
  matcher = {
    name = 'fzy',
  },
  sources = {
    search_buffer_source,
  },
}))

vim.api.nvim_create_user_command('CmpToggle', function()
  if enabled then
    enabled = false
    vim.api.nvim_notify('nvim-cmp disabled', vim.log.levels.INFO, {})
  else
    enabled = true
    vim.api.nvim_notify('nvim-cmp enabled', vim.log.levels.INFO, {})
  end
end, {})

vim.api.nvim_create_user_command('CmpDisable', function()
  enabled = false
end, {})

vim.api.nvim_create_user_command('CmpEnable', function()
  enabled = true
end, {})

return M
