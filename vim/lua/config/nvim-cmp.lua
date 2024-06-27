local cmp = require('cmp')

local M = {}

-- from lazyvim
---@param entry cmp.Entry
function M.auto_brackets(entry)
  local cmp = require("cmp")
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

local opts = {
  completion = {
    completeopt = 'menuone,noinsert',
  },
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      --vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<C-b>'] = cmp.mapping.scroll_docs(-3),
    ['<C-f>'] = cmp.mapping.scroll_docs(3),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
    { name = 'vsnip' },
    --{ name = 'nvim_lsp_signature_help' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  }),
}

cmp.setup(opts)

cmp.event:on('confirm_done', function (event)
  M.auto_brackets(event.entry)
end)
