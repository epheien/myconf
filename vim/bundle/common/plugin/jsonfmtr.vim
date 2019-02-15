" json formatter
" Author:   fanhe <fanhed@163.com>
" License:  GPLv2
" Create:   1970-01-01
" Change:   2018-05-31

if exists('g:loaded_jsonfmtr')
    finish
endif
let g:loaded_jsonfmtr = 1

if !has('python3') && !has('python')
    echoerr "Error: Required vim compiled with +python or +python3"
    finish
endif

let s:initpyif = 0
function s:InitPyif()
    if s:initpyif
        return
    endif
pythonx << PYTHON_EOF
import sys
import vim
import json

def JsonFmtr(**kwargs):
    mswindows = (sys.platform == "win32")
    buff = vim.current.buffer
    try:
        # set encoding=utf-8 可以避免 Windows 的编码问题
        s = '\n'.join(buff)
        if not s:
            return
        import json5
        obj = json5.loads(s)
    except (ImportError, ValueError) as e:
        try:
            obj = json.loads(s)
        except ValueError as e:
            raise e
    k = {
        'indent': 4,
        'sort_keys': 1,
        'ensure_ascii': 0,
        'separators': [',', ': '],
    }
    for key, val in k.items():
        k[key] = type(val)(kwargs.get(key, val))
    if k['indent'] == 0:
        k['indent'] = None
        k['separators'] = [',', ':']
    output = json.dumps(obj, **k)
    buff[:] = output.splitlines()
PYTHON_EOF
    let s:initpyif = 1
endfunction

" indent, sort_keys, ensure_ascii
function! s:JsonFmtr(...)
    let d = {}
    let d['indent'] = get(a:000, 0, 4)
    let d['sort_keys'] = get(a:000, 1, 1)
    let d['ensure_ascii'] = get(a:000, 1, 0)
    call s:InitPyif()
    pyx JsonFmtr(**vim.eval('d'))
endfunction

command! -nargs=* JsonFmtr call <SID>JsonFmtr(<f-args>)

" vim:fdm=marker:fen:et:sts=4:fdl=1:
