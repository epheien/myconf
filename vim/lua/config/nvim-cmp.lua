local cmp = require('cmp')

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
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'path' },
    { name = 'vsnip' },
    --{ name = 'nvim_lsp_signature_help' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  }),
}

cmp.setup(opts)
