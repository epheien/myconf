syntax clear goTodo
syn keyword goTodo TODO FIXME XXX BUG containedin=goCommentGroup contained
" 单独处理 NOTE 语法高亮
syn keyword goNote NOTE contained
syn cluster goCommentGroup add=goNote
hi def link goNote Special
