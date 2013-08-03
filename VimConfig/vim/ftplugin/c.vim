"command! OmniCppComplete call omnicpp#complete#Init()
setlocal complete=.,k
setlocal dictionary+=~/.vim/dict/cpp-keyword.list

if exists('g:c_kernel_mode') && g:c_kernel_mode
    setlocal tabstop=8
    setlocal softtabstop=0
    setlocal shiftwidth=8
    setlocal noexpandtab
else
    setlocal tabstop=4
    setlocal softtabstop=4
    setlocal shiftwidth=4
    setlocal expandtab
endif
