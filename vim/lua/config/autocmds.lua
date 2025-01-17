local vimrc_group = vim.api.nvim_create_augroup('vimrc', {})

-- smartim by hammerspoon
if vim.fn.has('mac') == 1 then
  vim.api.nvim_create_augroup('smartim', {})
  vim.api.nvim_create_autocmd({ 'VimEnter', 'VimLeavePre', 'InsertLeave', 'FocusGained' }, {
    callback = function() vim.system({ 'open', '-g', 'hammerspoon://toEnIM' }) end,
  })
end

-- rfc 文件格式支持
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  pattern = '*.txt',
  callback = function()
    if vim.regex([[rfc\d\+\.txt]]):match_str(vim.fn.expand('%:t') or '') then
      vim.bo.filetype = 'rfc'
    end
  end,
})

if vim.env.SSH_TTY then
  vim.api.nvim_create_autocmd('InsertLeave', {
    callback = function() vim.cmd.OSCYank('toEnIM()') end,
  })
end

-- from vimrc sample by Bram
-- When editing a file, always jump to the last known cursor position.
-- Don't do it when the position is invalid or when inside an event handler
-- (happens when dropping a file on gvim).
-- Also don't do it when the mark is in the first line, that is the default
-- position when opening a file.
--autocmd vimrc BufReadPost *
--    \ if line("'\"") > 1 && line("'\"") <= line("$") |
--    \     exe "normal! g`\"" |
--    \ endif
vim.api.nvim_create_autocmd('BufReadPost', {
  group = vimrc_group,
  callback = function()
    local lnum = vim.fn.line([['"]])
    if lnum > 1 and lnum <= vim.api.nvim_buf_line_count(0) then
      vim.cmd.normal({ args = { [[g`"]] }, bang = true })
    end
  end,
})

vim.api.nvim_create_autocmd('TermOpen', {
  group = vimrc_group,
  callback = function(event)
    if vim.bo.buftype ~= 'terminal' then
      return
    end
    -- 判断 snacks_dashboard 是否完成了显示
    if vim.fn.exists(':Capture') ~= 2 then
      return
    end
    vim.opt_local.list = false
    vim.opt_local.number = false
    vim.opt_local.cursorline = true
    vim.api.nvim_create_autocmd('WinEnter', {
      buffer = event.buf,
      callback = function()
        if vim.api.nvim_win_get_cursor(0)[1] == vim.api.nvim_buf_line_count(0) then
          vim.cmd.startinsert()
        end
      end,
    })
    vim.cmd.startinsert()
  end,
})

vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  group = vimrc_group,
  callback = function() vim.o.helplang = '' end,
})

-- 隐藏混乱的文件格式中的 ^M 字符
vim.api.nvim_create_autocmd('BufReadPost', {
  nested = true,
  callback = function() vim.call('myrc#FixDosFmt') end,
})

-- • Enabled treesitter highlighting for:
--   • Treesitter query files
--   • Vim help files
--   • Lua files
-- 额外的默认使用 treesitter 的文件类型
-- 事件顺序: BufReadPre => FileType => BufReadPost
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'c', 'vim', 'markdown' },
  callback = function()
    if vim.bo.filetype == 'markdown' then
      -- 非 floating window 用 treesiter 高亮, 否则就用 syntax 高亮
      if vim.api.nvim_win_get_config(0).relative == '' then
        vim.treesitter.start()
      end
    else
      vim.treesitter.start()
    end
  end,
})

vim.api.nvim_create_autocmd('BufWinEnter', {
  pattern = '*',
  callback = function()
    if vim.bo.filetype == 'help' and vim.api.nvim_win_get_config(0).relative ~= '' then
      local opt = vim.opt_local.winhighlight
      if not opt:get().NormalFloat then
        opt:append({ NormalFloat = 'Normal' })
      end
    end
  end,
})

-- 替换 spellfile.vim 标准插件的实现
vim.api.nvim_create_autocmd('SpellFileMissing', {
  callback = function(args) vim.call('spellfile#LoadFile', args.match) end,
})

vim.api.nvim_create_autocmd({ 'FileType', 'SessionLoadPost' }, {
  group = vimrc_group,
  callback = function(args) require('config/indent-line').indentchar_update(true, args.match) end,
})

vim.api.nvim_create_autocmd({ 'OptionSet' }, {
  pattern = { 'shiftwidth', 'expandtab', 'tabstop' },
  group = vimrc_group,
  callback = function()
    if vim.opt_local.listchars:get().leadmultispace then
      require('config/indent-line').indentchar_update(vim.v.option_type == 'local')
    end
  end,
})

vim.api.nvim_create_autocmd('ColorScheme', {
  -- 修改一些插件的高亮组, 需要插件初始化的时候用了 default 属性
  callback = function(event) ---@diagnostic disable-line
    -- 这个高亮原始值是 Visual, 在大多数主题下效果都不好, 必须修改
    vim.api.nvim_set_hl(0, 'ScrollView', { link = 'PmenuThumb' })
    -- snacks dashboard 的描述和图标默认使用同一配色, 不易分辨, 改掉
    vim.api.nvim_set_hl(0, 'SnacksDashboardDesc', { link = 'Normal' })

    if event.match == 'gruvbox' then
      -- 不使用默认的状态栏, 直接清空状态栏高亮
      vim.api.nvim_set_hl(0, 'StatusLine', {})
      vim.api.nvim_set_hl(0, 'StatusLineNC', {})
      -- 这个配色默认情况下，字符串和函数共用一个配色，要换掉！
      vim.api.nvim_set_hl(0, 'String', { link = 'Constant' })
      -- 终端下的光标颜色貌似不受主题的控制，受制于终端自身的设置
      vim.cmd.hi('Cursor guifg=black guibg=#dddd00 gui=NONE ctermfg=16 ctermbg=226 cterm=NONE')
      vim.cmd.hi('Todo guifg=orangered guibg=yellow2 gui=NONE ctermfg=202 ctermbg=226 cterm=NONE')
      --vim.cmd.hi('IncSearch guifg=#b0ffff guibg=#2050d0 ctermfg=159 ctermbg=26')
      vim.cmd.hi('Search guifg=gray80 guibg=#445599 gui=NONE ctermfg=252 ctermbg=61 cterm=NONE')
      vim.cmd.hi('Directory guifg=#8094b4 gui=bold ctermfg=12 cterm=bold')
      vim.cmd.hi({ args = { 'FoldColumn', 'guibg=NONE', 'ctermbg=NONE' } })
      vim.api.nvim_set_hl(0, 'Added', { link = 'DiagnosticOk' })
      vim.api.nvim_set_hl(0, 'Changed', { link = 'DiagnosticHint' })
      vim.api.nvim_set_hl(0, 'Removed', { link = 'DiagnosticError' })

      -- tagbar 配色
      vim.api.nvim_set_hl(0, 'TagbarAccessPublic', { link = 'GruvboxAqua' })
      vim.api.nvim_set_hl(0, 'TagbarAccessProtected', { link = 'GruvboxPurple' })
      vim.api.nvim_set_hl(0, 'TagbarAccessPrivate', { link = 'GruvboxRed' })
      vim.api.nvim_set_hl(0, 'TagbarSignature', { link = 'Normal' })
      vim.api.nvim_set_hl(0, 'TagbarKind', { link = 'Constant' })

      vim.api.nvim_set_hl(0, 'CurSearch', { link = 'Search' })
      vim.api.nvim_set_hl(0, 'FloatBorder', { link = 'WinSeparator' })
      vim.api.nvim_set_hl(0, 'SpecialKey', { link = 'Special' })
      vim.cmd.hi({ args = { 'SignColumn', 'guibg=NONE', 'ctermbg=NONE' } })
      -- NonText 和 WinSeparator 同时降低一个色阶, 避免过于明显
      vim.api.nvim_set_hl(0, 'NonText', { link = 'GruvboxBg1' })
      vim.api.nvim_set_hl(0, 'WinSeparator', { link = 'GruvboxBg2' })

      -- GitGutter
      vim.api.nvim_set_hl(0, 'GitGutterAdd', { link = 'GruvboxGreen' })
      vim.api.nvim_set_hl(0, 'GitGutterChange', { link = 'GruvboxAqua' })
      vim.api.nvim_set_hl(0, 'GitGutterDelete', { link = 'GruvboxRed' })
      vim.api.nvim_set_hl(0, 'GitGutterChangeDelete', { link = 'GruvboxYellow' })

      -- Signature
      vim.api.nvim_set_hl(0, 'SignatureMarkText', { link = 'GruvboxBlue' })
      vim.api.nvim_set_hl(0, 'SignatureMarkerText', { link = 'GruvboxPurple' })

      -- edgy.nvim
      vim.api.nvim_set_hl(0, 'EdgyNormal', { link = 'Normal' })
      -- scrollview
      vim.api.nvim_set_hl(0, 'ScrollViewDiagnosticsHint', { link = 'DiagnosticHint' })
      vim.api.nvim_set_hl(0, 'ScrollViewDiagnosticsInfo', { link = 'DiagnosticInfo' })
      vim.api.nvim_set_hl(0, 'ScrollViewDiagnosticsWarn', { link = 'DiagnosticWarn' })
      vim.api.nvim_set_hl(0, 'ScrollViewDiagnosticsError', { link = 'DiagnosticError' })
      vim.api.nvim_set_hl(0, 'ScrollViewHover', { link = 'PmenuSel' })
      vim.api.nvim_set_hl(0, 'ScrollViewRestricted', { link = 'ScrollView' })
      -- telescope
      vim.api.nvim_set_hl(0, 'TelescopeBorder', { link = 'WinSeparator', force = true })
      vim.api.nvim_set_hl(0, 'TelescopeTitle', { link = 'Title', force = true })
      vim.api.nvim_set_hl(0, 'TelescopeSelection', { link = 'CursorLine' })
      -- nvim-cmp
      vim.api.nvim_set_hl(0, 'CmpItemAbbrMatch', { link = 'SpecialChar' })
      vim.api.nvim_set_hl(0, 'CmpItemAbbrMatchFuzzy', { link = 'SpecialChar' })
      vim.api.nvim_set_hl(0, 'CmpItemMenu', { link = 'String' })
      vim.api.nvim_set_hl(0, 'CmpItemKind', { link = 'Identifier' })
      -- snacks
      vim.api.nvim_set_hl(0, 'SnacksDashboardHeader', { link = 'Directory' })
      vim.api.nvim_set_hl(0, 'SnacksDashboardDesc', { link = 'Normal' })
      -- neo-tree
      vim.api.nvim_set_hl(0, 'NeoTreeDirectoryName', { link = 'Title' })
      -- nvim-tree 的 ? 浮窗使用了 border, 所以需要修改背景色
      vim.api.nvim_set_hl(0, 'NvimTreeNormalFloat', { link = 'Normal' })
      vim.api.nvim_set_hl(0, 'NvimTreeFolderName', { link = 'Title' })
      vim.api.nvim_set_hl(0, 'NvimTreeOpenedFolderName', { link = 'Title' })
      vim.api.nvim_set_hl(0, 'NvimTreeSymlinkFolderName', { link = 'Title' })
    elseif event.match == 'base46' or event.match == 'onedark-nvchad' then
      vim.api.nvim_set_hl(0, 'CmpItemAbbrMatchFuzzy', { link = 'CmpItemAbbrMatch' })
      vim.api.nvim_set_hl(0, 'StatusLine', {})
      vim.api.nvim_set_hl(0, 'NonText', { link = 'WinSeparator' })
      vim.api.nvim_set_hl(0, 'FoldColumn', { link = 'Comment' })
      vim.api.nvim_set_hl(0, 'FloatTitle', { link = 'Title' })
      vim.api.nvim_set_hl(0, '@operator', { link = 'Operator' })
      vim.api.nvim_set_hl(0, 'Operator', { link = 'SpecialChar' })
      vim.api.nvim_set_hl(0, 'CurSearch', { link = 'Search' })
      vim.api.nvim_set_hl(0, 'NormalFloat', {
        fg = vim.api.nvim_get_hl(0, { name = 'Normal' }).fg,
        bg = vim.api.nvim_get_hl(0, { name = 'CursorLine' }).bg,
      })
      -- Function 就是 Title 的非粗体颜色
      vim.api.nvim_set_hl(0, 'DiagnosticOk', { link = 'Function' })
      -- Title 循例要粗体
      vim.cmd.hi({ args = { 'Title', 'gui=bold' } })
      vim.api.nvim_set_hl(0, '@markup.list.checked', { link = 'Added' })
      vim.api.nvim_set_hl(0, '@markup.list.unchecked', { link = 'Comment' })
      -- telescope
      vim.api.nvim_set_hl(0, 'TelescopePromptCounter', { link = 'SpecialKey' })
      vim.cmd.hi('TelescopeMatching guibg=NONE')
      -- edgy.nvim
      vim.api.nvim_set_hl(0, 'EdgyNormal', { link = 'Normal' })
      -- nvim-tree
      vim.api.nvim_set_hl(0, 'NvimTreeFolderIcon', { link = 'Directory' })
      vim.api.nvim_set_hl(0, 'NvimTreeSymlink', { link = 'Special' })
    end
  end,
})
