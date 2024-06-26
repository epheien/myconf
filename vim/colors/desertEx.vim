" Vim color file
" Maintainer:   Mingbai <mbbill AT gmail DOT com>
" Last Change:  2006-12-24 20:09:09

set background=dark
if version > 580
    " no guarantees for version 5.8 and below, but this makes it stop
    " complaining
    hi clear
    if exists("syntax_on")
        syntax reset
    endif
endif
let g:colors_name="desertEx"

hi Normal       guifg=gray guibg=grey17 gui=none

" AlignCtrl default
" AlignCtrl =P0 guifg guibg gui
" Align

" highlight groups
hi Cursor       guifg=black          guibg=yellow   gui=none
hi ErrorMsg     guifg=white          guibg=red      gui=none
hi VertSplit    guifg=gray40         guibg=gray29   gui=none
hi Folded       guifg=gray60         guibg=grey17   gui=underline
"hi FoldColumn   guifg=tan            guibg=grey30   gui=none
"hi FoldColumn   guifg=DarkSlateGray3 guibg=grey17   gui=none
hi FoldColumn   guifg=gray60         guibg=grey17   gui=none
hi IncSearch    guifg=#b0ffff        guibg=#2050d0
hi LineNr       guifg=burlywood3     gui=none
hi ModeMsg      guifg=SkyBlue        gui=none
hi MoreMsg      guifg=SeaGreen       gui=none
"hi NonText      guifg=cyan           gui=none
hi NonText      guifg=grey40         gui=none
hi Question     guifg=springgreen    gui=none
hi Search       guifg=gray80         guibg=#445599  gui=none
hi SpecialKey   guifg=cyan           gui=none
hi StatusLine   guifg=black          guibg=#c2bfa5  gui=bold
hi StatusLineNC guifg=grey           guibg=gray29   gui=none
"hi Title        guifg=indianred      gui=none
hi Title        guifg=mediumpurple1  gui=none
hi Visual       guifg=gray17         guibg=tan1     gui=none
hi WarningMsg   guifg=salmon         gui=none
hi Pmenu        guifg=white          guibg=#445599  gui=none
hi PmenuSel     guifg=#445599        guibg=gray
hi PmenuThumb   guifg=white          guibg=white
hi WildMenu     guifg=black          guibg=yellow   gui=bold
hi MatchParen   guifg=cyan           guibg=NONE     gui=bold
hi DiffAdd      guifg=black          guibg=wheat1
hi DiffChange   guifg=black          guibg=skyblue1
hi DiffText     guifg=black          guibg=hotpink1 gui=none
hi DiffDelete   guibg=gray45         guifg=black    gui=none
hi Conceal      guifg=grey40         guibg=grey17   gui=none

" Custom add
hi ColorColumn  guibg=grey20
hi CursorLine   guibg=grey20
"hi ColorColumn ctermbg=blue
hi SignColumn   guibg=grey17


" syntax highlighting groups
"hi Comment      guifg=PaleGreen3     gui=italic
hi Comment      guifg=PaleGreen3     gui=none
hi Constant     guifg=salmon         gui=none
hi Identifier   guifg=mediumpurple1  gui=none
hi Function     guifg=Skyblue        gui=none
hi Statement    guifg=lightgoldenrod2 gui=none
hi PreProc      guifg=PaleVioletRed2 gui=none
hi Type         guifg=tan1           gui=none
hi Special      guifg=aquamarine2    gui=none
hi Ignore       guifg=grey40         gui=none
hi Todo         guifg=orangered      guibg=yellow2 gui=none

" vi:set et sts=4 sw=4:
