if exists('g:loaded_jsonfmtr')
    finish
endif
let g:loaded_jsonfmtr = 1

if !has('python')
    echoerr "Error: Required vim compiled with +python"
    finish
endif

py import sys
py import json
py import vim

python << PYTHON_EOF
def JsonFmtr():
    buff = vim.current.buffer
    try:
        obj = json.loads('\n'.join(buff))
    except ValueError, e:
        raise e
    output = json.dumps(obj, sort_keys=True, indent=4, ensure_ascii=False)
    buff[:] = output.encode('utf-8').splitlines()
PYTHON_EOF

function! JsonFmtr()
    py JsonFmtr()
endfunction

" vim:fdm=marker:fen:et:sts=4:fdl=1:
