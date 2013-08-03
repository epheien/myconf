" escalt.vim    控制台下让用 <M-x> 也可用
" Author:       lilydjwg <lilydjwg@gmail.com>
" Last Change:  2010年12月15日
" ---------------------------------------------------------------------
" Load Once:
if &cp || exists("g:loaded_escalt") || has("gui_running") || has("win32") || has("win64")
  finish
endif
let s:keepcpo = &cpo
let g:loaded_escalt = 1
set cpo&vim
" ---------------------------------------------------------------------
" Functions:
function Escalt_console()
  for i in range(65, 90) + range(97, 122)
    exe "set <M-".nr2char(i).">=\<Esc>".nr2char(i)
  endfor
  set ttimeoutlen=50
  if &term =~ 'xterm'
    set <F1>=OP
    set <F2>=OQ
    set <F3>=OR
    set <F4>=OS
    set <Home>=OH
    set <End>=OF
  endif
  if exists("$TMUX")
    set <S-F1>=[1;2P
    set <S-F2>=[1;2Q
    set <S-F3>=[1;2R
    set <S-F4>=[1;2S
    set <S-F5>=[15;2~
    set <S-F6>=[17;2~
    set <S-F7>=[18;2~
    set <S-F8>=[19;2~
    set <S-F9>=[20;2~
    set <S-F10>=[21;2~
    set <S-F11>=[23;2~
    set <S-F12>=[24;2~
  else
    for i in ["", "c", "i", "x"]
      exe i . "map Ï1;2P <S-F1>"
      exe i . "map Ï1;2Q <S-F2>"
      exe i . "map Ï1;2R <S-F3>"
      exe i . "map Ï1;2S <S-F4>"
    endfor
  endif
endfunction
" ---------------------------------------------------------------------
" Call Functions:
call Escalt_console()
" ---------------------------------------------------------------------
" Restoration And Modelines:
let &cpo= s:keepcpo
unlet s:keepcpo
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
