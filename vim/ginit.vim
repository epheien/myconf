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
set guicursor&

" vim:set fdm=marker fen fdl=0 sw=4 sts=-1 et:
