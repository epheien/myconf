setlocal softtabstop=4
setlocal tabstop&
setlocal shiftwidth=4
setlocal expandtab

command -buffer -bang CppAlternate call mycpp#alternateSwitch(<bang>0, '')
