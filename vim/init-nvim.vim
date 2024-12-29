" ========== neosnippet ==========
let g:neosnippet#snippets_directory = [expand('~/.vim/snippets')]

" ========== coc.nvim ==========
" CocInstall coc-neosnippet
" CocInstall coc-json
let g:coc_snippet_next = ''
let g:coc_snippet_prev = ''
let g:coc_data_home = stdpath('config') .. '/coc'
" 补全后自动弹出函数参数提示
" 一般按<CR>确认补全函数后, 会自动添加括号并让光标置于括号中
autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')

" ========== clang-format ==========
let g:clang_format#code_style = 'llvm'
" NOTE: 不能指定 IndentWidth 和 UseTab, 因为插件自动设置了, 重复设置会出错!
let g:clang_format#style_options = {
    "\ 'IndentWidth': 4,
    \ 'AlwaysBreakTemplateDeclarations': v:true,
    \ 'BinPackArguments': v:false,
    \ 'BinPackParameters': v:false,
    \ 'ColumnLimit': 100,
    \ 'IndentCaseLabels': v:false,
    \ 'DerivePointerAlignment': v:false,
    \ 'PointerAlignment': 'Left',
    \ 'AccessModifierOffset': -4,
    \ 'ReflowComments': v:false,
    \ 'SortIncludes': v:true,
    \ 'IncludeBlocks': 'Preserve',
    \ 'AllowShortFunctionsOnASingleLine': 'Empty',
    \ 'AllowShortIfStatementsOnASingleLine': v:false,
    \ 'SpacesBeforeTrailingComments': 1,
    \ }

" ----------------------------------------------------------------------------
" vim: fdm=marker fen fdl=0 sw=4 sts=-1 et
