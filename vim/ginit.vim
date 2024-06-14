" NOTE: nvim-qt 无法使用设置 vim 选项的方向调整窗口大小
if has('mac')
    " nvim-qt -qwindowgeometry 633x632 "$@"
    set guifont=SFMono\ Nerd\ Font:h12
    if get(g:, 'gonvim_running', 0)
        let g:line_ppp = 14
        let g:column_ppp = 7
        silent! GuiTabline 0
        silent! GuiPopupmenu 0
        autocmd OptionSet * call myrc#optionset_hook()
    endif
elseif has('win32') || has('win64')
    " nvim-qt.exe -qwindowgeometry 720x765
    GuiLinespace -1
    GuiFont! Microsoft YaHei Mono:h11
endif

if get(g:, 'neovide')
    set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
        \,a:blinkwait500-blinkoff500-blinkon500-Cursor/lCursor
        \,sm:block-blinkwait175-blinkoff150-blinkon175
    let s:guicursor = &guicursor
    " 经过逐像素对比, 0.84 在 macOS 12.7.5 (MacBook Pro) 上效果和 iTerm 一致
    set guifont=SFMono\ Nerd\ Font:h12:w-0.84
    if has('mac')
        map <D-v> <C-v>
        cmap <D-v> <C-v>
        tmap <D-v> <C-v>
        "inoremap <silent> <D-v> <C-r>=myrc#prepIpaste()<CR><C-r>"<C-r>=myrc#postIpaste()<CR>
        imap <D-v> <C-v>
    endif
    let g:gutentags_ctags_executable = expand('~/bin/ctags')
    let g:tagbar_ctags_bin = expand('~/bin/ctags')
    " 修正一些常用的 <M- 快捷键问题
    " FIXME: <M-n> 无法实现, 已确认为 bug, 待修复, 当前版本使用临时方案
    function s:LazySetupNeovide(...)
        let g:neovide_input_macos_option_key_is_meta = 'only_left'
    endfunc
    call timer_start(200, 's:LazySetupNeovide')
    autocmd FocusGained * let &guicursor = s:guicursor
    autocmd FocusLost * set guicursor=a:Cursor/lCursor
else
    set guicursor&
endif

" gui 的工作目录总是 /, 需要改过来
cd ~

" vim:set fdm=marker fen fdl=0 sw=4 sts=-1 et:
