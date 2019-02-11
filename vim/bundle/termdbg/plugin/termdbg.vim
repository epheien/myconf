if !has('terminal')
  echoerr 'termdbg need compliled with +terminal'
  finish
endif

if exists('s:loaded')
  finish
endif
let s:loaded = 1

command -nargs=+ -complete=file -bang Termdbg
      \ call termdbg#StartDebug(<bang>0, '', <f-args>)
command -nargs=+ -complete=file -bang TermdbgPdb
      \ call termdbg#StartDebug(<bang>0, 'pdb', g:termdbg_pdb_prog, <f-args>)
command -nargs=+ -complete=file -bang TermdbgPdb3
      \ call termdbg#StartDebug(<bang>0, 'pdb3', g:termdbg_pdb3_prog, <f-args>)
command -nargs=+ -complete=file -bang TermdbgIPdb
      \ call termdbg#StartDebug(<bang>0, 'ipdb', g:termdbg_ipdb_prog, <f-args>)
command -nargs=+ -complete=file -bang TermdbgIPdb3
      \ call termdbg#StartDebug(<bang>0, 'ipdb3', g:termdbg_ipdb3_prog, <f-args>)
