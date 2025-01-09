local M = {}

M.config = {
  style = 'default',
}

local prefix = 'onedark-nvchad.default.'

local modules = {
  --'colors', -- ignore

  -- nvim 内置必需
  'defaults',
  'syntax',
  'term',
  'treesitter',
  'lsp',

  -- 必用插件必需
  'cmp',
  --'nvimtree',
  'devicons',

  'telescope',
  --'whichkey',
  --'blankline',
  --'git',
  --'mason',
  --'nvcheatsheet',
  --'statusline',
  --'tbline',
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
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})
  if M.config.style == 'soft' then
    prefix = 'onedark-nvchad.soft.'
  else
    prefix = 'onedark-nvchad.default.'
  end
end

return M
