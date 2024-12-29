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

" 颜色方案
" https://hm66hd.csb.app/ 真彩色 => 256色 在线工具
" 转换逻辑可在 unused/CSApprox 插件找到 (会跟在线工具有一些差别, 未深入研究)
function s:SetupColorscheme(colors_name) "{{{
    " 这个选项能直接控制 gruvbox 的 sign 列直接使用 LineNr 列的高亮组
    let g:gitgutter_override_sign_column_highlight = 1
    if &t_Co == 256     " 支持 256 色的话
        set background=dark
        try
            exec 'colorscheme' a:colors_name
        catch
            echomsg 'colorscheme ' .. a:colors_name .. ' failed, fallback to gruvbox-origin'
            colorscheme gruvbox-origin
        endtry
    endif
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

" NOTE: 为了避免无谓的闪烁, 把终端的背景色设置为和 vim/nvim 一致即可
if $TERM_PROGRAM =~# '\V\<Apple_Terminal'
    Plug 'epheien/bg.nvim'
endif

" 基础配色, 但不在这里加载, 因为时机有点晚
Plug 'epheien/gruvbox.nvim', {'on': '<Plug>(gruvbox-placeholder)'}

call plug#end()
" ####

if $TERM_PROGRAM !=# 'Apple_Terminal'
    call s:SetupColorscheme('gruvbox')
endif

if exists(':Rg') != 2
    command! -nargs=+ -complete=customlist,myrc#FileComplete Rg call myrc#rg(<q-args>)
endif

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
