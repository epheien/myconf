" json formatter
" Author:   fanhe <fanhed@163.com>
" License:  GPLv2
" Create:   1970-01-01
" Change:   2018-05-31

if exists('g:loaded_jsonfmtr')
    finish
endif
let g:loaded_jsonfmtr = 1

if !has('python3')
    echoerr "Error: Required vim compiled with +python3"
    finish
endif

let s:initpyif = 0
function s:InitPyif()
    if s:initpyif
        return
    endif
python3 << PYTHON_EOF
import sys
import vim
try:
    import json5 as json
except ImportError:
    import json

def JsonFmtr():
    mswindows = (sys.platform == "win32")
    buff = vim.current.buffer
    try:
        obj = json.loads('\n'.join(buff))
    except ValueError as e:
        raise e
    output = json.dumps(obj, sort_keys=True, indent=4, ensure_ascii=False,
                        separators=[',', ': '])
    buff[:] = output.splitlines()
PYTHON_EOF
    let s:initpyif = 1
endfunction

function! s:JsonFmtr()
    call s:InitPyif()
    py3 JsonFmtr()
endfunction

command! -nargs=0 JsonFmtr call <SID>JsonFmtr()

" vim:fdm=marker:fen:et:sts=4:fdl=1:
