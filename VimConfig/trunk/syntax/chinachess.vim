" Vim syntax file
" Language:     chinachess
" Maintainer:   fanhe <fanhed@163.com>
" Create:       2011-11-21

" Quit when a (custom) syntax file was already loaded
if exists("b:current_syntax")
    finish
endif

syn match red '車\|馬\|砲\|仕\|相\|兵\|帥\|(\|)'
syn match black '车\|马\|炮\|士\|象\|卒\|将\|\[\|\]'
syn match gray '１\|２\|３\|４\|５\|６\|７\|８\|９\|九\|八\|七\|六\|五\|四\|三\|二\|一\|楚\|河\|汉\|界\|+\|-\||\|x\|#\|╲\|╱'
set background=light
highlight black     gui=bold guifg=Black guibg=LightGray
highlight red       gui=bold guifg=Red guibg=LightGray
highlight gray      gui=None guifg=DarkGray guibg=LightGray
highlight Normal    gui=None guifg=Black guibg=LightGray
hi clear MatchParen
highlight MatchParen gui=None guibg=Gray
highlight Cursor    gui=None guifg=LightGray guibg=Blue

" vim: fdm=marker fen et sts=4 fdl=1
