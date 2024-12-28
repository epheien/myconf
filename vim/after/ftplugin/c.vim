setlocal softtabstop=4
setlocal tabstop&
setlocal shiftwidth=4
setlocal expandtab

nnoremap <buffer> <silent> [[ :<C-U>call mycpp#BlockJumpPrev()<CR>
