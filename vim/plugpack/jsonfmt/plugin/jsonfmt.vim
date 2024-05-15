" json formatter
" Author:   fanhe <fanhed@163.com>
" License:  GPLv2
" Create:   1970-01-01
" Change:   2018-05-31

if exists('g:loaded_jsonfmt')
    finish
endif
let g:loaded_jsonfmt = 1

if !has('python3')
    echoerr "Error: jsonfmt required vim compiled with +python3"
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
import json

def JsonFmt(**kwargs):
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
        'sort_keys': 0,
        'ensure_ascii': 1,
        'separators': [',', ': '],
    }
    for key, val in k.items():
        k[key] = type(val)(kwargs.get(key, val))
    if k['indent'] < 0:
        k['indent'] = None
        k['separators'] = [',', ':']
    output = json.dumps(obj, **k)
    buff[:] = output.splitlines()
PYTHON_EOF
    let s:initpyif = 1
endfunction

" indent, sort_keys, ensure_ascii
function! s:JsonFmt(...)
    let d = {}
    if get(a:000, 0, '') =~# '-h\|--help'
        echo 'Usage: JsonFmt [{indent}, [{sort_keys}, [{ensure_ascii}]]]'
        echo 'Default Params: indent=4, sort_keys=0, ensure_ascii=0'
        return
    endif
    let d['indent'] = get(a:000, 0, 4)
    let d['sort_keys'] = get(a:000, 1, 0)
    let d['ensure_ascii'] = get(a:000, 2, 0)
    call s:InitPyif()
    py3 JsonFmt(**vim.eval('d'))
endfunction

command! -nargs=* JsonFmt call <SID>JsonFmt(<f-args>)

" vim:fdm=marker:fen:et:sts=4:fdl=1:
