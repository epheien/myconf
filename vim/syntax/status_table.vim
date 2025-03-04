" 允许装载自定义语法文件
if exists("b:current_syntax")
    finish
endif

" 激活的按钮
syntax match StatusTableActiveButton '\V[[\[^][]\+]]' display
" 未激活的按钮
syntax match StatusTableButton '\V[\[^][]\+]' display

" 表格标题
syntax match StatusTableTitle '\V\^=====\.\+=====\ze\[^=]\*' contains=StatusTableRemark
" 表格备注
syntax match StatusTableRemark ' ===== .\+$'hs=s+6 contained
" 表头标题
syntax match StatusTableHeader '[^|]\+[↓↑? ]|'hs=s+1,he=e-2 contained
syntax match StatusTableHeader '[^│]\+[↓↑? ]│'hs=s+1,he=e-2 contained contains=StatusTableSortGlyph
syntax match StatusTableSortGlyph '[↓↑?]' contained

syntax region StatusTableHeaders start='\v^(\||│) ' end='\v[↓↑? ](\|\n^\+\=|│\n├)' oneline contains=StatusTableHeader

" Numbers
" ------------------------------
syn match StatusTableNumber         display     '\<\d\+\>'
syn match StatusTableNumberFloat    display     '\<\d\+\.\d\+\([eE][+-]\?\d\+\)\?\>'
syn match StatusTableNumberBin      display     '\<0[bB][01]\+\>'
syn match StatusTableNumberOctal    display     '\<0[oO]\o\+\>'
syn match StatusTableNumberHex      display     '\<0[xX]\x\+\>'

syn match StatusTableDuration       display     '\<\d\+\(\.\d\+\)\?\(ns\|us\|µs\|ms\|[smh]\)\>'

syn match StatusTableSymbol    display     '[!@#$%^&*;:?]'

hi def link StatusTableNumber           Number
hi def link StatusTableNumberFloat      Float
hi def link StatusTableNumberBin        Number
hi def link StatusTableNumberOctal      Number
hi def link StatusTableNumberHex        Number

hi def link StatusTableSymbol           Delimiter
hi def link StatusTableSortGlyph        Special
hi def link StatusTableDuration         Type

highlight def link StatusTableButton Special
highlight def link StatusTableActiveButton Todo
highlight def link StatusTableTitle Title
highlight def link StatusTableRemark Comment
highlight def link StatusTableHeader Identifier
