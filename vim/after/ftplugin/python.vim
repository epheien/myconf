" 去掉烦人的卡成 shit 的 python 自动补全
setlocal omnifunc=
silent! iunmap <buffer> .

" 调整缩进习惯
let g:python_indent = {}
let g:python_indent.open_paren = 'shiftwidth()'
let g:python_indent.closed_paren_align_last_line = v:false
