return {
  'ellisonleao/gruvbox.nvim',
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
      terminal_colors = vim.env['SSH_CONNECTION'] and true,
      overrides = {
        GruvboxRedSign = { bg = 'NONE' },
        GruvboxGreenSign = { bg = 'NONE' },
        GruvboxYellowSign = { bg = 'NONE' },
        GruvboxBlueSign = { bg = 'NONE' },
        GruvboxPurpleSign = { bg = 'NONE' },
        GruvboxAquaSign = { bg = 'NONE' },
        GruvboxOrangeSign = { bg = 'NONE' },

        NvimTreeFolderIcon = { link = 'Directory' },
        Directory = { fg = '#8094b4', bold = true },
        String = { link = 'Constant' },
        Todo = { fg = 'orangered', bg = 'yellow2' },
        Search = { fg = 'gray80', bg = '#445599', reverse = false },
        CurSearch = { link = 'Search' },
        SpecialKey = { link = 'Special' },
        FoldColumn = { bg = 'NONE' },
        SignColumn = { link = 'FoldColumn' },
        StatusLine = { link = '@none' }, -- 避免闪烁, 最终会被 mystl 覆盖
        WinBarNC = { bg = 'NONE' },

        -- NonText 和 WinSeparator 同时降低一个色阶, 避免过于明显
        NonText = { link = 'GruvboxBg1' },
        WinSeparator = { link = 'GruvboxBg2' },
        FloatBorder = { link = 'WinSeparator' },

        -- 补充缺失的高亮设置
        Added = { link = 'DiagnosticOk' },
        Changed = { link = 'DiagnosticHint' },
        Removed = { link = 'DiagnosticError' },

        -- 覆盖 telescope 全套高亮
        TelescopeNormal = { link = 'Normal' },
        TelescopeSelection = { link = 'CursorLine' },
        TelescopeSelectionCaret = { link = 'TelescopeSelection' },
        TelescopeMultiSelection = { link = 'Type' },
        TelescopeBorder = { link = 'WinSeparator' },
        TelescopePromptBorder = { link = 'TelescopeBorder' },
        TelescopeResultsBorder = { link = 'TelescopeBorder' },
        TelescopePreviewBorder = { link = 'TelescopeBorder' },
        TelescopeMatching = { link = 'Special' },
        TelescopePromptPrefix = { link = 'Identifier' },
        --TelescopePrompt = { link = 'TelescopeNormal' },
        TelescopePromptCounter = { link = 'TelescopeBorder' },

        -- volt highlights
        ExRed = { link = 'GruvboxRed' },
        ExBlue = { link = 'GruvboxBlue' },
        ExGreen = { link = 'GruvboxGreen' },
        ExYellow = { link = 'GruvboxYellow' },

        -- 修改 treesiter 部分配色
        ['@variable'] = { link = '@none' },
        ['@constructor'] = { link = '@function' },
        ['markdownCodeBlock'] = { link = 'markdownCode' },
        ['markdownCode'] = { link = 'String' },
        ['markdownCodeDelimiter'] = { link = 'Delimiter' },
        ['markdownOrderedListMarker'] = { link = 'markdownListMarker' },
        ['markdownListMarker'] = { link = 'Tag' },
      },
    })
    if vim.env.TERM_PROGRAM ~= 'Apple_Terminal' then
      vim.o.background = 'dark'
      require('gruvbox').load()
      vim.api.nvim_exec_autocmds('ColorScheme', { modeline = false, pattern = vim.g.colors_name })
    end
  end,
}
