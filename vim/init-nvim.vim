" 表示是否仅使用 ASCII 显示
let s:only_ascii = -1
function g:OnlyASCII() "{{{
    if s:only_ascii >= 0
      return s:only_ascii
    endif
    " 对于现代的终端, 只要设置支持 nerd font 的字体即可支持非 ASCII 模式
    if has('gui_running') || $TERM_PROGRAM =~# '\V\<iTerm\|\<Apple_Terminal\|\<kitty\|\<alacritty\|\<tmux'
        let s:only_ascii = 0
    else
        let s:only_ascii = 1
    endif
    return s:only_ascii
endfunction
"}}}

" 激活 bundle 目录的插件, 优先于 Plug
call pathogen#infect()
" 设置 nvim 主题
" 写成一行, 避免默认的语法解释出现奇怪的问题
silent! lua require('gruvbox').setup({bold=true, italic={strings=false, emphasis=false, comments=false, operators=false, folds=false},
    \ terminal_colors=vim.fn.has('gui_running')==1})

let g:plug_window = 'new'
" ## vim-plug
" NOTE: 对于依赖程度高的或者复杂的插件，需要锁定版本
" NOTE: 对于 nvim, 必须安装 python 模块: pip3 install -U pynvim
call plug#begin(stdpath('config') .. '/plugged')

Plug 'junegunn/vim-plug' " NOTE: 重复安装 plug 是为了看帮助信息
Plug 'yianwillis/vimcdoc' " 中文文档
Plug 'asins/vim-dict'
Plug 'tpope/vim-surround'

Plug 'tweekmonster/helpful.vim', {'on': 'HelpfulVersion'} " 获取特性加入/删除的具体版本

" 新增语法支持
Plug 'vobornik/vim-mql4'
"Plug 'othree/yajs.vim' " 增强的 js 语法高亮

Plug 'dstein64/vim-startuptime', {'on': 'StartupTime'}
Plug 'sunaku/vim-dasht', {'on': 'Dasht'}
Plug 'yuratomo/w3m.vim', {'on': 'W3m'}
Plug 'Yggdroot/LeaderF', {'on': 'Leaderf'}
Plug 'mbbill/undotree', {'on': 'UndotreeShow'}
Plug 'iamcco/markdown-preview.vim', {'for': 'markdown'}
Plug 'dhruvasagar/vim-table-mode', {'on': 'TableModeToggle'}
Plug 'skywind3000/asyncrun.vim', {'on': 'AsyncRun'}
Plug 'kassio/neoterm', {'on': 'Tnew'}
Plug 'epheien/nerdtree', {'on': 'NERDTree'} " orig: 'preservim/nerdtree'
Plug 'epheien/tagbar', {'on': 'TagbarToggle'}
Plug 'epheien/vim-clang-format', {'on': 'ClangFormat'}
Plug 'epheien/videm', {'on': 'VidemOpen'}

" 基础配色, 但不在这里加载, 因为时机有点晚
Plug 'epheien/gruvbox.nvim', {'on': '<Plug>(gruvbox-placeholder)'}

call plug#end()
" ####

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
