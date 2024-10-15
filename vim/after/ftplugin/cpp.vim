setlocal softtabstop=4
setlocal tabstop&
setlocal shiftwidth=4
setlocal expandtab

nnoremap <buffer> <silent> [[ :<C-U>call mycpp#BlockJumpPrev()<CR>

command -buffer -bang CppAlternate call mycpp#alternateSwitch(<bang>0, '')
