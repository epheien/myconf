" ============================================================================
" 基本设定
" ============================================================================

function s:IsWindowsOS() "{{{
    return has("win32") || has("win64")
endfunction
"}}}
function s:IsUnixOS() "{{{
    return has('unix')
endfunction
"}}}
function s:IsLinuxOS() "{{{
    return !s:IsWindowsOS()
endfunction
"}}}
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
function s:joinpath(...) "{{{
    let sep = '/'
    if s:IsWindowsOS()
        let sep = '\'
    endif
    return join(a:000, sep)
endfunction
"}}}
" 用户配置文件所在的目录
let s:USERRUNTIME = stdpath('config')

" vimrc 配置专用自动命令组
augroup vimrc
augroup END

function s:SetupColorschemePost(...) "{{{
    if g:colors_name ==# 'gruvbox'
        " 这个配色默认情况下，字符串和函数共用一个配色，要换掉！
        hi! link String Constant
        " 终端下的光标颜色貌似不受主题的控制，受制于终端自身的设置
        hi Cursor guifg=black guibg=yellow gui=NONE ctermfg=16 ctermbg=226 cterm=NONE
        hi Todo guifg=orangered guibg=yellow2 gui=NONE ctermfg=202 ctermbg=226 cterm=NONE
        hi IncSearch guifg=#b0ffff guibg=#2050d0 ctermfg=159 ctermbg=26
        hi Search guifg=gray80 guibg=#445599 gui=NONE ctermfg=252 ctermbg=61 cterm=NONE
        " tagbar 配色
        hi! link TagbarAccessPublic GruvboxAqua
        hi! link TagbarAccessProtected GruvboxPurple
        hi! link TagbarAccessPrivate GruvboxRed
        hi! link TagbarSignature Normal
        hi! link TagbarKind Constant
        hi! link CurSearch Search
        hi! link FloatBorder WinSeparator
        hi! link SpecialKey Special
        hi! SignColumn guibg=NONE ctermbg=NONE
        " GitGutter
        hi! link GitGutterAdd GruvboxGreen
        hi! link GitGutterChange GruvboxAqua
        hi! link GitGutterDelete GruvboxRed
        hi! link GitGutterChangeDelete GruvboxYellow
        " Signature
        hi! link SignatureMarkText   GruvboxBlue
        hi! link SignatureMarkerText GruvboxPurple
    endif
    " 配合 incline
    "hi Normal guibg=NONE ctermbg=NONE " 把 Normal 高亮组的背景色去掉, 可避免一些配色问题
    let normalHl = nvim_get_hl(0, {'name': 'Normal', 'link': v:false})
    let winSepHl = nvim_get_hl(0, {'name': 'WinSeparator', 'link': v:false})
    let fg = printf('#%06x', get(winSepHl, get(winSepHl, 'reverse') ? 'bg' : 'fg'))
    let bg = printf('#%06x', get(normalHl, get(normalHl, 'reverse') ? 'fg' : 'bg'))
    let ctermfg = get(winSepHl, get(winSepHl, 'reverse') ? 'ctermbg' : 'ctermfg')
    let ctermbg = get(normalHl, get(normalHl, 'reverse') ? 'ctermfg' : 'ctermbg')
    call nvim_set_hl(0, 'StatusLine', {'fg': fg, 'bg': bg, 'ctermfg': ctermfg, 'ctermbg': ctermbg})
    hi! link StatusLineNC StatusLine
    if &statusline !~# '^%!\|^%{%'
        set statusline=─
    endif
    set fillchars+=stl:─,stlnc:─
endfunction
"}}}
autocmd vimrc ColorScheme * call s:SetupColorschemePost(expand("<afile>"), expand("<amatch>"))

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

" Man
command -nargs=+ -complete=shellcmd Man call myrc#Man('Man', <q-mods>, <q-args>)

command -nargs=+ -complete=file RefreshStatusTables call myrc#RefreshStatusTables(<f-args>)

" 选择后立即搜索
xnoremap / y:let @" = substitute(@", '\\', '\\\\', "g")<CR>
    \:let @" = substitute(@", '\/', '\\\/', "g")<CR>/\V<C-r>"<CR>N


" ============================================================================
" 插件设置
" ============================================================================
" 激活 bundle 目录的插件, 优先于 Plug
call pathogen#infect()
" 设置 nvim 主题
" 写成一行, 避免默认的语法解释出现奇怪的问题
silent! lua require('gruvbox').setup({bold=true, italic={strings=false, emphasis=false, comments=false, operators=false, folds=false},
    \ terminal_colors=vim.fn.has('gui_running')==1})

" ========== NERD commenter ==========
"{{{
let NERDMenuMode = 0
let g:NERDCreateDefaultMappings = 0
let g:NERDCustomDelimiters = {
    \ 'python': {'left': '#'},
    \ }
"let NERDSpaceDelims = 1
func s:nmap_ctrl_n()
    if get(g:, 'termdbg_running')
        TNext
    else
        call plug#load('nerdcommenter')
        call nerdcommenter#Comment("n", "Toggle")
        call feedkeys("\<Down>")
    endif
endfunc
nnoremap <silent> <C-n> :call <SID>nmap_ctrl_n()<CR>
"}}}
" ========== pydiction ==========
"{{{
let g:pydiction_location = s:USERRUNTIME . '/dict/complete-dict'
"let g:pydiction_menu_height = 20
"}}}
" ========== videm ==========
"{{{
let g:videm_user_options = {
    \ 'videm.wsp.ShowBriefHelp'            : 0,
    \ 'videm.wsp.SaveBeforeBuild'          : 1,
\ }
" ========== mark ==========
"{{{
function! s:MouseMark() "{{{2
    if &ft == "help"
        execute "normal! \<C-]>"
        return
    endif
    let c = getline('.')[col('.')-1]
    if &buftype ==# 'quickfix'
        call myrc#MyEnter()
        return
    elseif c == '(' || c == ')' || c == '[' || c == ']' || c == '{' || c == '}'
        execute "normal! \<2-LeftMouse>"
        return
    endif
    call feedkeys("\<Plug>MarkSet")
endfunction
"}}}2
let g:mwIgnoreCase = 0
let g:mwHistAdd = ''
" 'extended' 的话, 颜色不是太好看
"let g:mwDefaultHighlightingPalette = 'extended'
"}}}
" ========== vim-signature ==========
"{{{
let g:SignaturePeriodicRefresh = 0
let g:SignatureMap = {
  \ 'PlaceNextMark'      :  "m,",
  \ 'PurgeMarks'         :  "m<Space>",
  \ 'GotoNextSpotByPos'  :  "<F2>",
  \ 'GotoPrevSpotByPos'  :  "<S-F2>",
  \ 'ListBufferMarks'    :  "m/",
  \ }
"}}}
" ============================================================================
" IDE 设置
" ============================================================================
let g:c_kernel_mode = 1

command -nargs=0 CKernelMode setlocal ts=8 sts=0 sw=8 noet
command -nargs=0 CSpaceMode setlocal ts=8 sts=4 sw=4 et
command -nargs=0 CTS4ETMode setlocal ts=4 sts=4 sw=4 et
" 清理后置的多余的空白
command -nargs=0 CleanSpaces silent! %s/\s\+$//g | noh | normal! ``

inoremap <expr> ; <SID>i_Semicolon_plus()

function! s:i_Semicolon_plus() "{{{
    let sLine = getline('.')
    if sLine !~# '^\s*for\>' && sLine[col('.') - 1] ==# ')'
        return "\<Right>;"
    else
        return ";"
    endif
endfunction
"}}}
" ========== cscope 设置 ==========
"{{{
command -complete=file -nargs=+ CsFind call myrc#CscopeFind(<q-args>)
"}}}

function s:Plug(name, ...)
    let plug = printf('my/%s', a:name)
    let opt = {'dir': s:joinpath(s:USERRUNTIME, 'plugpack', a:name)}
    let opt['frozen'] = 1
    let opt = extend(opt, get(a:000, 0, {}))
    exec printf('Plug %s, %s', string(plug), string(opt))
endfunction

let g:plug_window = 'new'
" ## vim-plug
" NOTE: 对于依赖程度高的或者复杂的插件，需要锁定版本
" NOTE: 对于 nvim, 必须安装 python 模块: pip3 install -U pynvim
call plug#begin(s:joinpath(s:USERRUNTIME, 'plugged'))

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
Plug 'preservim/nerdcommenter', {'on': '<Plug>NERDCommenterToggle'}
Plug 'epheien/tagbar', {'on': 'TagbarToggle'}
Plug 'epheien/vim-clang-format', {'on': 'ClangFormat'}
" 自己的插件
"Plug 'epheien/termdbg', {'on': 'Termdbg'}
Plug 'epheien/videm', {'on': 'VidemOpen'}

" NOTE: 为了避免无谓的闪烁, 把终端的背景色设置为和 vim/nvim 一致即可
if $TERM_PROGRAM =~# '\V\<Apple_Terminal'
    Plug 'epheien/bg.nvim'
endif

" 基础配色, 但不在这里加载, 因为时机有点晚
Plug 'epheien/gruvbox.nvim', {'on': '<Plug>(gruvbox-placeholder)'}

" 本地插件
call s:Plug('common')
call s:Plug('vim-repeat') " autoload
call s:Plug('mymark', {'on': ['<Plug>MarkSet', '<Plug>MarkAllClear']})
call s:Plug('python-syntax', {'for': 'python'})
call s:Plug('jsonfmt', {'on': 'JsonFmt'})
call s:Plug('colorizer', {'on': 'UpdateColor'})
call s:Plug('colorsel', {'on': 'ColorSel'})
call s:Plug('visincr', {'on': 'I'})

call plug#end()
" ####

" ========== Plug 安装的插件的配置，理论上不应过长 ==========
"let g:gruvbox_contrast_dark = 'hard'
let g:gruvbox_italic = 0 " gruvbox 主题的斜体设置, 中文无法显示斜体, 所以不用
let g:mkdp_auto_close = 0 " markdown-preview 禁止自动关闭
let g:asyncrun_open = 5 " asyncrun 自动打开 quickfix

autocmd vimrc VimEnter * ++once set helplang=

" 长期缓存, 如保存到文件, 这样的话, 重开 vim 就不会重建缓存
let g:Lf_UseCache = 0
" 短期缓存, 会在内存缓存, 如果文件经常改动的话, 就不适合了
"let g:Lf_UseMemoryCache = 0
" 不使用版本控制机制，要的是简单粗暴直接磁盘搜索！
let g:Lf_UseVersionControlTool = 0
" Up 和 Down 使用 C-P 和 C-N
let g:Lf_CommandMap = {'<C-K>': ['<C-K>', '<Up>'], '<C-J>': ['<C-J>', '<Down>']}
if g:OnlyASCII()
    let g:Lf_StlSeparator = { 'left': '', 'right': '', 'font': '' }
else
    let g:Lf_StlSeparator = { 'left': '', 'right': '', 'font': '' }
endif
let g:Lf_WindowPosition = 'popup'
"autocmd vimrc filetype * if &ft == 'leaderf' | setl nonumber | endif

if $TERM_PROGRAM !=# 'Apple_Terminal'
    call s:SetupColorscheme('gruvbox')
endif

if exists(':Rg') != 2
    command! -nargs=+ -complete=customlist,myrc#FileComplete Rg call myrc#rg(<q-args>)
endif

" gutentags
let g:gutentags_define_advanced_commands = 1
let g:gutentags_file_list_command = 'cat gtags.files'
let g:gutentags_ctags_tagfile = 'gutags'
let g:gutentags_add_default_project_roots = 0
let g:gutentags_project_root = ['gtags.files']
let g:gutentags_auto_add_gtags_cscope = 0 " 这个必须设置为 0, 避免 nvim 报错
let g:gutentags_modules = []
if executable('ctags')
    let g:gutentags_modules += ['ctags']
endif
if executable('gtags-cscope') && executable('gtags')
    if has('nvim-0.9')
        let g:gutentags_modules += ['cscope_maps']
        let g:gutentags_cscope_executable_maps = 'gtags'
    else
        let g:gutentags_modules += ['gtags_cscope']
    endif
endif
" ctags 的一些参数
let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']
" 这两个选项会导致 ctags 退出码有异常, 禁用掉
"let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
"let g:gutentags_ctags_extra_args += ['--c-kinds=+px']
"let g:gutentags_trace = 1

" ==========================================================
" 自己的简易插件
" ==========================================================
" ========== 隐藏混乱的文件格式中的 ^M 字符 ==========
"{{{
autocmd BufReadPost * nested call <SID>FixDosFmt()
function! s:FixDosFmt() "{{{2
    if &ff != 'unix' || &bin || &buftype =~# '\<quickfix\>\|\<nofile\>'
        return
    endif
    if &ft ==# 'vim' " vimp.vim 会存在特殊字符, 不处理这种文件类型
        return
    endif
    " 打开常见的图像文件类型的话, 不处理, 一般会有对应的插件处理
    if expand('%:e') =~? '^\(png\|jpg\|jpeg\|gif\|bmp\|webp\|tif\|tiff\)$'
        return
    endif
    " 搜索 ^M
    let nStopLine = 0
    let nTimeOut = 100
    let nRet = search('\r$', 'nc', nStopLine, nTimeOut)
    if nRet > 0
        e ++ff=dos
        echohl WarningMsg
        echomsg "'fileformat' of buffer" bufname('%') 'has been set to dos'
        echohl None
    endif
endfunction
"}}}2
"}}}

" ========== neosnippet ==========
let g:neosnippet#snippets_directory = [expand('~/.vim/snippets')]

" ========== coc.nvim ==========
" CocInstall coc-neosnippet
" CocInstall coc-json
let g:coc_snippet_next = ''
let g:coc_snippet_prev = ''
let g:coc_data_home = s:joinpath(s:USERRUNTIME, 'coc')
" 补全后自动弹出函数参数提示
" 一般按<CR>确认补全函数后, 会自动添加括号并让光标置于括号中
autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')

" ========== table-mode ==========
" 兼容 markdown 表格格式
let g:table_mode_corner = '|'
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

" ========== gitgutter ==========
let g:gitgutter_sign_added = '┃'
let g:gitgutter_sign_modified = '┃'
let g:gitgutter_sign_modified_removed = '~'
let g:gitgutter_diff_args = '--ignore-cr-at-eol'
if !has('gui_running')
    let g:gitgutter_terminal_reports_focus = 0
endif

" ========== scrollview ==========
" macOS iTerm2 色差 (-1, 0, 2)
" 137 => 136 129 => 129 109 => 111
"highlight ScrollView ctermbg=243 guibg=#89816d
highlight link ScrollView PmenuThumb
let scrollview_auto_mouse = v:false

" ----------------------------------------------------------------------------
" vim: fdm=marker fen fdl=0 sw=4 sts=-1 et
