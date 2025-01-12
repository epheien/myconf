return {
  'epheien/gruvbox.nvim',
  priority = 1000,
  lazy = vim.g.my_colors_name ~= 'gruvbox',
  config = function()
    require('gruvbox').setup({
      bold = true,
      italic = {
        strings = false,
        emphasis = false,
        comments = false,
        operators = false,
        folds = false,
      },
      terminal_colors = vim.fn.has('gui_running') == 1,
    })
    if vim.env.TERM_PROGRAM ~= 'Apple_Terminal' then
      vim.o.background = 'dark'
      require('gruvbox').load()
      vim.api.nvim_exec_autocmds('ColorScheme', { modeline = false, pattern = vim.g.colors_name })
    end
    -- TODO: 放到 ColorScheme callback
    -- gruvbox.nvim 的这几个配色要覆盖掉
    local names = {
      'GruvboxRedSign',
      'GruvboxGreenSign',
      'GruvboxYellowSign',
      'GruvboxBlueSign',
      'GruvboxPurpleSign',
      'GruvboxAquaSign',
      'GruvboxOrangeSign',
    }
    for _, name in ipairs(names) do
      local opts = vim.api.nvim_get_hl(0, { name = name, link = false })
      if not vim.tbl_isempty(opts) then
        opts.bg = nil
        vim.api.nvim_set_hl(0, name, opts) ---@diagnostic disable-line
      end
    end
    -- 修改 treesiter 部分配色
    vim.api.nvim_set_hl(0, '@variable', {})
    vim.api.nvim_set_hl(0, '@constructor', { link = '@function' })
    vim.api.nvim_set_hl(0, 'markdownCodeBlock', { link = 'markdownCode' })
    vim.api.nvim_set_hl(0, 'markdownCode', { link = 'String' })
    vim.api.nvim_set_hl(0, 'markdownCodeDelimiter', { link = 'Delimiter' })
    vim.api.nvim_set_hl(0, 'markdownOrderedListMarker', { link = 'markdownListMarker' })
    vim.api.nvim_set_hl(0, 'markdownListMarker', { link = 'Tag' })
  end,
}
