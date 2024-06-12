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
        \,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
        \,sm:block-blinkwait175-blinkoff150-blinkon175
else
    set guicursor&
endif

" gui 的工作目录总是 /, 需要改过来
cd ~

" vim:set fdm=marker fen fdl=0 sw=4 sts=-1 et:
