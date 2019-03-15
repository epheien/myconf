" NOTE: nvim-qt 无法使用设置 vim 选项的方向调整窗口大小
if has('mac')
    " nvim-qt -qwindowgeometry 630x630 "$@"
    set guifont=Menlo:h12
elseif has('win32') || has('win64')
    " nvim-qt.exe -qwindowgeometry 720x765
    GuiLinespace -1
    GuiFont! Microsoft YaHei Mono:h11
endif
GuiTabline 0
GuiPopupmenu 0
set guicursor&
