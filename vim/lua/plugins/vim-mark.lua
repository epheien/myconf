local function setup_colors()
  -- 现代的彩色 7 色名称
  -- 红橙黄绿青蓝紫
  -- Red Orange  Yellow Green Cyan Blue Violet
  local palette = {
    { fg = 'Black', bg = '#FF7272', ctermfg = 'Black', ctermbg = 'Red' },
    { fg = 'Black', bg = '#FFA672', ctermfg = 'Black', ctermbg = 'Magenta' }, -- 推算出来的橙色
    { fg = 'Black', bg = '#FFDB72', ctermfg = 'Black', ctermbg = 'Yellow' },
    { fg = 'Black', bg = '#A4E57E', ctermfg = 'Black', ctermbg = 'Green' },
    { fg = 'Black', bg = '#8CCBEA', ctermfg = 'Black', ctermbg = 'Cyan' },
    { fg = 'Black', bg = '#9999FF', ctermfg = 'Black', ctermbg = 'Blue' },
    { fg = 'Black', bg = '#FFB3FF', ctermfg = 'Black', ctermbg = 'White' },
  }

  for i = 1, #palette do
    vim.api.nvim_set_hl(0, string.format('MarkWord%d', i), palette[i])
  end

  -- catppuccin
  --vim.api.nvim_set_hl(0, 'MarkWord1', { fg = 'Black', bg = '#df8c97' })
  --vim.api.nvim_set_hl(0, 'MarkWord2', { fg = 'Black', bg = '#eaac86' })
  --vim.api.nvim_set_hl(0, 'MarkWord3', { fg = 'Black', bg = '#ead5a5' })
  --vim.api.nvim_set_hl(0, 'MarkWord4', { fg = 'Black', bg = '#b1d89c' })
  --vim.api.nvim_set_hl(0, 'MarkWord5', { fg = 'Black', bg = '#8dc2e0' })
  --vim.api.nvim_set_hl(0, 'MarkWord6', { fg = 'Black', bg = '#c0a1f0' })
end

return {
  'epheien/vim-mark',
  keys = { { '<Plug>MarkSet', mode = { 'n', 'x' } }, '<Plug>MarkAllClear' },
  dependencies = { 'inkarkat/vim-ingo-library' },
  config = function()
    vim.api.nvim_create_autocmd('ColorScheme', {
      callback = setup_colors,
    })
    setup_colors()
  end,
}
