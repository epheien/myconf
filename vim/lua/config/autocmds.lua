local vimrc_group = vim.api.nvim_create_augroup('vimrc', {})

-- smartim by hammerspoon
if vim.fn.has('mac') == 1 then
  vim.api.nvim_create_augroup('smartim', {})
  vim.api.nvim_create_autocmd({ 'VimEnter', 'VimLeavePre', 'InsertLeave', 'FocusGained' }, {
    callback = function()
      vim.system({ 'open', '-g', 'hammerspoon://toEnIM' })
    end
  })
end

-- rfc 文件格式支持
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  pattern = '*.txt',
  callback = function()
    if vim.regex([[rfc\d\+\.txt]]):match_str(vim.fn.expand('%:t') or '') then
      vim.bo.filetype = 'rfc'
    end
  end
})

if vim.env.SSH_TTY then
  vim.api.nvim_create_autocmd('InsertLeave', {
    callback = function()
      vim.cmd.OSCYank('toEnIM()')
    end,
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
  end
})

vim.api.nvim_create_autocmd('TermOpen', {
  group = vimrc_group,
  callback = function(event)
    if vim.bo.buftype ~= 'terminal' then return end
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
  end
})

vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  group = vimrc_group,
  callback = function() vim.o.helplang = '' end
})

vim.cmd([[
function g:SetupColorschemePost(...)
  if g:colors_name ==# 'gruvbox'
    " 这个配色默认情况下，字符串和函数共用一个配色，要换掉！
    hi! link String Constant
    " 终端下的光标颜色貌似不受主题的控制，受制于终端自身的设置
    hi Cursor guifg=black guibg=yellow gui=NONE ctermfg=16 ctermbg=226 cterm=NONE
    hi Todo guifg=orangered guibg=yellow2 gui=NONE ctermfg=202 ctermbg=226 cterm=NONE
    hi IncSearch guifg=#b0ffff guibg=#2050d0 ctermfg=159 ctermbg=26
    hi Search guifg=gray80 guibg=#445599 gui=NONE ctermfg=252 ctermbg=61 cterm=NONE
    " tagbar 配色
    hi! link TagbarAccessPublic GruvboxAqua
    hi! link TagbarAccessProtected GruvboxPurple
    hi! link TagbarAccessPrivate GruvboxRed
    hi! link TagbarSignature Normal
    hi! link TagbarKind Constant
    hi! link CurSearch Search
    hi! link FloatBorder WinSeparator
    hi! link SpecialKey Special
    hi! SignColumn guibg=NONE ctermbg=NONE
    " GitGutter
    hi! link GitGutterAdd GruvboxGreen
    hi! link GitGutterChange GruvboxAqua
    hi! link GitGutterDelete GruvboxRed
    hi! link GitGutterChangeDelete GruvboxYellow
    " Signature
    hi! link SignatureMarkText   GruvboxBlue
    hi! link SignatureMarkerText GruvboxPurple
  endif
  " 配合 incline
  "hi Normal guibg=NONE ctermbg=NONE " 把 Normal 高亮组的背景色去掉, 可避免一些配色问题
  let normalHl = nvim_get_hl(0, {'name': 'Normal', 'link': v:false})
  let winSepHl = nvim_get_hl(0, {'name': 'WinSeparator', 'link': v:false})
  let fg = printf('#%06x', get(winSepHl, get(winSepHl, 'reverse') ? 'bg' : 'fg'))
  let bg = printf('#%06x', get(normalHl, get(normalHl, 'reverse') ? 'fg' : 'bg'))
  let ctermfg = get(winSepHl, get(winSepHl, 'reverse') ? 'ctermbg' : 'ctermfg')
  let ctermbg = get(normalHl, get(normalHl, 'reverse') ? 'ctermfg' : 'ctermbg')
  call nvim_set_hl(0, 'StatusLine', {'fg': fg, 'bg': bg, 'ctermfg': ctermfg, 'ctermbg': ctermbg})
  hi! link StatusLineNC StatusLine
  if &statusline !~# '^%!\|^%{%'
    set statusline=─
  endif
  set fillchars+=stl:─,stlnc:─
endfunction
]])

vim.api.nvim_create_autocmd('ColorScheme', {
  group = vimrc_group,
  callback = function(args)
    vim.call('g:SetupColorschemePost', args.file, args.match)
  end
})

-- 隐藏混乱的文件格式中的 ^M 字符
vim.api.nvim_create_autocmd('BufReadPost', {
  nested = true,
  callback = function()
    vim.call('myrc#FixDosFmt')
  end
})

-- • Enabled treesitter highlighting for:
--   • Treesitter query files
--   • Vim help files
--   • Lua files
-- 额外的默认使用 treesitter 的文件类型
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
  end
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
  end
})
