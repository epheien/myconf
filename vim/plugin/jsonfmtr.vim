" json formatter
" Author:   fanhe <fanhed@163.com>
" License:  GPLv2
" Create:   1970-01-01
" Change:   2015-09-04

if exists('g:loaded_jsonfmtr')
    finish
endif
let g:loaded_jsonfmtr = 1

if !has('python')
    echoerr "Error: Required vim compiled with +python"
    finish
endif

let s:initpyif = 0
function s:InitPyif()
    if s:initpyif
        return
    endif
python << PYTHON_EOF
import sys
import json
import vim

def JsonFmtr():
    mswindows = (sys.platform == "win32")
    buff = vim.current.buffer
    try:
        if mswindows:
            obj = json.loads('\n'.join(buff).decode('cp936'))
        else:
            obj = json.loads('\n'.join(buff).decode('utf-8'))
    except ValueError, e:
        raise e
    output = json.dumps(obj, sort_keys=True, indent=4, ensure_ascii=False)
    if mswindows:
        buff[:] = output.splitlines()
    else:
        buff[:] = output.encode('utf-8').splitlines()
PYTHON_EOF
    let s:initpyif = 1
endfunction

function! s:JsonFmtr()
    call s:InitPyif()
    py JsonFmtr()
endfunction

command! -nargs=0 JsonFmtr call <SID>JsonFmtr()

" vim:fdm=marker:fen:et:sts=4:fdl=1:
