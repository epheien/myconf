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
let g:colors_name="desertEx256"

highlight Normal guifg=gray guibg=grey17 gui=NONE ctermfg=250 ctermbg=235 cterm=NONE

" AlignCtrl default
" AlignCtrl =P0 guifg guibg gui
" Align

" highlight groups
highlight Cursor guifg=black guibg=yellow gui=NONE ctermfg=16 ctermbg=226 cterm=NONE
highlight ErrorMsg guifg=white guibg=red gui=NONE ctermfg=231 ctermbg=196 cterm=NONE
highlight VertSplit guifg=gray40 guibg=gray29 gui=NONE ctermfg=241 ctermbg=239 cterm=NONE
highlight Folded guifg=darkslategray3 guibg=grey17 gui=underline ctermfg=116 ctermbg=235 cterm=underline
"hi FoldColumn   guifg=tan            guibg=grey30   gui=none
highlight FoldColumn guifg=darkslategray3 guibg=grey17 gui=NONE ctermfg=116 ctermbg=235 cterm=NONE
highlight IncSearch guifg=#b0ffff guibg=#2050d0 ctermfg=159 ctermbg=26
highlight LineNr guifg=burlywood3 gui=NONE ctermfg=180 cterm=NONE
highlight ModeMsg guifg=skyblue gui=NONE ctermfg=117 cterm=NONE
highlight MoreMsg guifg=seagreen gui=NONE ctermfg=29 cterm=NONE
highlight NonText guifg=cyan gui=NONE ctermfg=51 cterm=NONE
highlight Question guifg=springgreen gui=NONE ctermfg=48 cterm=NONE
highlight Search guifg=gray80 guibg=#445599 gui=NONE ctermfg=252 ctermbg=61 cterm=NONE
highlight SpecialKey guifg=cyan gui=NONE ctermfg=51 cterm=NONE
highlight StatusLine guifg=black guibg=#c2bfa5 gui=bold ctermfg=16 ctermbg=144 cterm=bold
highlight StatusLineNC guifg=grey guibg=gray29 gui=NONE ctermfg=250 ctermbg=239 cterm=NONE
" hi Title        guifg=indianred      gui=none
highlight Title guifg=mediumpurple1 gui=NONE ctermfg=141 cterm=NONE
highlight Visual guifg=gray17 guibg=tan1 gui=NONE ctermfg=235 ctermbg=215 cterm=NONE
highlight WarningMsg guifg=salmon gui=NONE ctermfg=210 cterm=NONE
highlight Pmenu guifg=white guibg=#445599 gui=NONE ctermfg=231 ctermbg=61 cterm=NONE
highlight PmenuSel guifg=#445599 guibg=gray ctermfg=61 ctermbg=250
highlight PmenuThumb guifg=white guibg=white ctermfg=231 ctermbg=231
highlight WildMenu guifg=black guibg=yellow gui=bold ctermfg=16 ctermbg=226 cterm=bold
highlight MatchParen guifg=cyan guibg=NONE gui=bold ctermfg=51 cterm=bold
highlight DiffAdd guifg=black guibg=wheat1 ctermfg=16 ctermbg=223
highlight DiffChange guifg=black guibg=skyblue1 ctermfg=16 ctermbg=117
highlight DiffText guifg=black guibg=hotpink1 gui=NONE ctermfg=16 ctermbg=205 cterm=NONE
highlight DiffDelete guifg=black guibg=gray45 gui=NONE ctermfg=16 ctermbg=243 cterm=NONE
highlight Conceal guifg=grey40 guibg=grey17 gui=NONE ctermfg=241 ctermbg=235 cterm=NONE

" Custom add
highlight ColorColumn guibg=grey20 ctermbg=236
highlight CursorLine guibg=grey20 ctermbg=236 cterm=NONE
"hi ColorColumn	ctermbg=blue
highlight SignColumn guibg=grey17 ctermbg=235


" syntax highlighting groups
"hi Comment      guifg=PaleGreen3     gui=italic
highlight Comment guifg=palegreen3 gui=NONE ctermfg=114 cterm=NONE
highlight Constant guifg=salmon gui=NONE ctermfg=210 cterm=NONE
highlight Identifier guifg=skyblue gui=NONE ctermfg=117 cterm=NONE
highlight Function guifg=skyblue gui=NONE ctermfg=117 cterm=NONE
highlight Statement guifg=lightgoldenrod2 gui=NONE ctermfg=186 cterm=NONE
highlight PreProc guifg=palevioletred2 gui=NONE ctermfg=211 cterm=NONE
highlight Type guifg=tan1 gui=NONE ctermfg=215 cterm=NONE
highlight Special guifg=aquamarine2 gui=NONE ctermfg=122 cterm=NONE
highlight Ignore guifg=grey40 gui=NONE ctermfg=241 cterm=NONE
highlight Todo guifg=orangered guibg=yellow2 gui=NONE ctermfg=202 ctermbg=226 cterm=NONE

highlight TabLineFill cterm=reverse
highlight TabLine cterm=reverse,underline ctermfg=NONE ctermbg=NONE
highlight TabLineSel cterm=bold ctermfg=141

" bug workround
set background=dark

" color terminal definitions
"highlight SpecialKey
"highlight NonText cterm=bold
"highlight Directory
"highlight ErrorMsg cterm=bold
"highlight IncSearch cterm=NONE
"highlight Search cterm=NONE
"highlight MoreMsg
"highlight ModeMsg cterm=NONE
"highlight LineNr
"highlight Question
"highlight StatusLine cterm=bold,reverse
"highlight StatusLineNC cterm=reverse
"highlight VertSplit cterm=reverse
"highlight Title
"highlight Visual cterm=reverse
"highlight VisualNOS cterm=bold,underline
"highlight WarningMsg
"highlight WildMenu
"highlight Folded
"highlight FoldColumn
"highlight DiffAdd
"highlight DiffChange
"highlight DiffDelete cterm=bold
"highlight DiffText cterm=bold
"highlight PmenuSel
"highlight PmenuSbar
"highlight PmenuThumb
"highlight Conceal
"highlight Comment
"highlight Constant
"highlight Special
"highlight Identifier
"highlight Statement
"highlight PreProc
"highlight Type
"highlight Underlined cterm=underline
"highlight Ignore
"highlight Error cterm=bold
