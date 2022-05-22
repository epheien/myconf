" ============================================================================
" 自定义高亮
" ============================================================================

" 高亮函数
syn match jsFunction display "\<[a-zA-Z_][a-zA-Z0-9_]*\>\ze\s*("
hi def link jsFunction Function

" function 标识符连接到普通标识符号的高亮, 避免和函数高亮组重复
hi link javaScriptFunction javaScriptIdentifier
