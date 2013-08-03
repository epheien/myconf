setlocal expandtab
setlocal smarttab
setlocal tabstop=4
setlocal shiftwidth=4


"运行 python 程序的快捷键
"map <F12> :!"%"<CR>
nnoremap <silent> <buffer> <F11> :update<CR>:silent !gnome-terminal -e "sh -c 'python \"%\"; echo \"------------------\" && echo \"Press return to continue\" &&  read i'"&<CR>
imap <F11> <Esc><F11>

inoremap <silent> <buffer> : <C-r>=<SID>i_Colon_plus()<CR>
function! s:i_Colon_plus() "{{{
	if getline('.')[col('.') - 1] == ')'
		return "\<Right>:"
	else
		return ":"
	endif
endf

inoremap <silent> <buffer> . .<C-x><C-o><C-p>
inoremap <silent> <buffer> ' ''<Left>

