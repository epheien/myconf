if exists("b:did_after_ftplugin")
  finish
endif
let b:did_after_ftplugin = 1

setlocal shiftwidth=4
setlocal softtabstop=-1
setlocal tabstop=4
setlocal expandtab&

nnoremap <buffer> <silent> [[ :<C-U>call <SID>BlockJumpPrev()<CR>

" NOTE: 无法分辨是否嵌套, 只会无脑往前搜索指定的 go 语法模式
function! s:BlockJumpPrev() abort
  call search('^[a-zA-Z_]\+.\+{$', 'bWs')
endfunction
