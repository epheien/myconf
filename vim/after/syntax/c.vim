" ============================================================================
" 自定义高亮
" ============================================================================

"syntax match mcLineContinue "\\$" contained

" 高亮注释中的 NOTE
syntax clear cTodo
syn keyword cTodo TODO FIXME XXX BUG containedin=cCommentGroup contained
syn keyword cNote NOTE contained
syn cluster cCommentGroup add=cNote
hi def link cNote Special

" 高亮宏定义
syn match mcMacro '^\s*#\s*\(if\|ifdef\|ifndef\|elif\|define\)\s\+\zs\<[a-zA-Z_][a-zA-Z0-9_]*\>\ze\s*' contains=mcMacroFunc containedin=cPreCondit
hi def link mcMacro Constant

" 高亮函数
syn match mcFunction display "\<[a-zA-Z_][a-zA-Z0-9_]*\>("me=e-1 
            \contains=cLineContinue
syn match mcFunction display "\<[a-zA-Z_][a-zA-Z0-9_]*\>\ze\s\+(" 
            \contains=cLineContinue
hi def link mcFunction Function

" 高亮常数宏，以全大写分辨
syn match mcMacroFunc display "\<[a-zA-Z_][a-zA-Z0-9_]*\>("me=e-1 
            \contained contains=cLineContinue containedin=cPreCondit
hi def link mcMacroFunc Function
syn match mcConstant display "\<[A-Z_][A-Z0-9_]*\>" contains=mcMacroFunc
hi def link mcConstant Constant

" 高亮 doxygen 单词
syn match mcDoxygenWord '@\w\+' containedin=cComment,cCommentL
hi def link mcDoxygenWord Question


syn match mcOperator display 
            \"+\|-\|\*\|/\|%\|=\|<\|>\|&\||\|!\|\~\|\^\|\.\|?\|:" 
            \contains=cComment,cCommentL
hi link mcOperator Operator

" vi:set et sts=4:
