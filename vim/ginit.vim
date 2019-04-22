" NOTE: nvim-qt 无法使用设置 vim 选项的方向调整窗口大小
if has('mac')
    " nvim-qt -qwindowgeometry 633x632 "$@"
    set guifont=Menlo:h12
    let g:line_ppp = 14
    let g:column_ppp = 7
    autocmd OptionSet * call myrc#optionset_hook()
elseif has('win32') || has('win64')
    " nvim-qt.exe -qwindowgeometry 720x765
    GuiLinespace -1
    GuiFont! Microsoft YaHei Mono:h11
endif
GuiTabline 0
GuiPopupmenu 0
set guicursor&
