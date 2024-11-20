" 允许装载自定义语法文件
if exists("b:current_syntax")
    finish
endif

" 激活的按钮
syntax match StatusTableActiveButton '\V[[\[^][]\+]]' display
" 未激活的按钮
syntax match StatusTableButton '\V[\[^][]\+]' display

" 表格标题
syntax match StatusTableTitle '\V\^=====\.\+=====\$' display
" 表头标题
syntax match StatusTableHeader '[^|]\+ |'hs=s+1,he=e-2 contained

syntax region StatusTitleAndHeaders start="^| " end=" |\n^+=" oneline contains=StatusTableHeader

highlight def link StatusTableButton Special
highlight def link StatusTableActiveButton Todo
highlight def link StatusTableTitle Function
highlight def link StatusTableHeader Identifier
