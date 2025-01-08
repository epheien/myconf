local M = {}

local prefix = 'onedark-nvchad.default.'

local modules = {
  'blankline',
  'cmp',
  --'colors', -- ignore
  'defaults',
  'devicons',
  'git',
  'lsp',
  'mason',
  'nvcheatsheet',
  'nvimtree',
  'statusline',
  'syntax',
  'tbline',
  'telescope',
  'term',
  'treesitter',
  'whichkey',
}

function M.base_load() require(prefix .. 'defaults') end

function M.extra_load()
  for _, mod in ipairs(modules) do
    if mod ~= 'defaults' then
      require(prefix .. mod)
    end
  end
end

function M.load()
  for _, mod in ipairs(modules) do
    require(prefix .. mod)
  end
end

function M.setup(opts)
  if opts.style == 'soft' then
    prefix = 'onedark-nvchad.soft.'
  else
    prefix = 'onedark-nvchad.default.'
  end
end

return M
