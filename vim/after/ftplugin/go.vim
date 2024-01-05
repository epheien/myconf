if exists("b:did_after_ftplugin")
  finish
endif
let b:did_after_ftplugin = 1

setlocal shiftwidth=4
setlocal softtabstop=-1
setlocal tabstop=4
setlocal expandtab&

nnoremap <buffer> <silent> [[ :<C-U>call mygo#BlockJumpPrev()<CR>

command -buffer GoFmt call mygo#GoFmt()
command -buffer -bang GoAlternate call mygo#alternateSwitch(<bang>0, '')
