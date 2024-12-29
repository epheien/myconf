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
if s:IsWindowsOS()
    let s:USERRUNTIME = s:joinpath($HOME, 'vimfiles')
else
    let s:USERRUNTIME = s:joinpath($HOME, '.vim')
endif

" vimrc 配置专用自动命令组
augroup vimrc
augroup END

" 禁用 vim 文件类型的错误
let g:vimsyn_noerror = 1
" 使用增强的 python 语法高亮的所有功能
let g:python_highlight_all = 1
" 禁用很慢的语法
let g:python_slow_sync = 0
" 对于 lisp，使用彩虹高亮括号匹配
let g:lisp_rainbow = 1
" 基于 syntax 的 markdown 代码块高亮可用的语言类型
let g:markdown_fenced_languages = ['html', 'python', 'vim', 'lua', 'cpp', 'c', 'go']
let g:markdown_syntax_conceal = 1

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
    if has('nvim')
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
    endif
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

" user PATH
if $PATH !~ expand('~/bin')
    let $PATH .= ':' . expand('~/bin')
endif

" 摘录自vimrc sample by Bram
" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
" Also don't do it when the mark is in the first line, that is the default
" position when opening a file.
autocmd vimrc BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \     exe "normal! g`\"" |
    \ endif

" 需要导出到子环境的环境变量
let $VIM_SERVERNAME = v:servername
let $VIM_EXE = v:progpath

" ============================================================================
" 额外的文件格式支持
" ============================================================================

" rfc 文件格式
autocmd vimrc BufNewFile,BufRead *.txt if expand('%:t') =~# 'rfc\d\+\.txt' | setf rfc | endif

" ============================================================================
" 常规键盘映射
" ============================================================================
" 最常用的复制粘贴
if !has('nvim') && has('clipboard')
    vnoremap <C-x> "+x
    vnoremap <C-c> "+y
    vnoremap <C-v> "+gP
    nnoremap <C-v> "+gP
    inoremap <C-v> <C-r>=myrc#prepIpaste()<CR><C-r>+<C-r>=myrc#postIpaste()<CR>
    cnoremap <C-v> <C-r>+
    if exists(':tmap')
        tnoremap <C-v> <C-w>"+
    endif
else
    vnoremap <silent> <C-x> ""x:call myrc#cby()<CR>
    vnoremap <silent> <C-c> ""y:call myrc#cby()<CR>
    vnoremap <silent> <C-v> "_d:<C-u>call myrc#cbp()<CR>""gP
    nnoremap <silent> <C-v> :call myrc#cbp()<CR>""gP
    inoremap <silent> <C-v> <C-r>=myrc#prepIpaste()<CR><C-r>=myrc#cbp()<CR><C-r>"<C-r>=myrc#postIpaste()<CR>
    cnoremap <silent> <C-v> <C-r>=myrc#cbp()<CR><C-r>=myrc#_paste()<CR>
    if exists(':tmap')
        tnoremap <silent> <C-v> <C-w>:call myrc#cbp()<CR><C-w>""
    endif
    command -nargs=0 OSCYankEnable  call myrc#enable_oscyank()
    command -nargs=0 OSCYankDisable call myrc#disable_oscyank()
endif

nnoremap <silent> <M-h> :tabNext<CR>
nnoremap <silent> <M-l> :tabnext<CR>
nnoremap <silent> <M-j> <C-w>-
nnoremap <silent> <M-k> <C-w>+
if exists(':tmap')
    if has('nvim')
        tnoremap <silent> <M-h> <C-\><C-n>:tabNext<CR>
        tnoremap <silent> <M-l> <C-\><C-n>:tabnext<CR>
    else
        tnoremap <silent> <M-h> <C-w>:tabNext<CR>
        tnoremap <silent> <M-l> <C-w>:tabnext<CR>
    endif
endif
inoremap <silent> <M-h> <C-\><C-o>:tabNext<CR>
inoremap <silent> <M-l> <C-\><C-o>:tabnext<CR>

" ======================================
" 普通模式
" ======================================
nnoremap <silent> \- :set columns-=30<CR>
nnoremap <silent> \= :set columns+=30<CR>
nnoremap <silent> \d :call myrc#n_BufferDelete()<CR>
nnoremap \h :lcd %:p:h <Bar> pwd<CR>
"nnoremap \] :mksession! vimp.vim <Bar> wviminfo! vimp.vi<CR>
" vim -S vimp.vim
nnoremap \] :mksession! vimp.vim<CR>
nnoremap <Space>    3<C-e>
nnoremap ,          3<C-y>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap ; :
nnoremap <silent> gq :call myrc#close()<CR>
"nnoremap Q gq " nvim 的 Q 命令含义以及改了, 但是未能在 vim 同等实现
" stty -ixon
func s:nmap_ctrl_s()
    if get(g:, 'termdbg_running')
        TStep
    else
        update
    endif
endfunc
nnoremap <silent> <C-s> :call <SID>nmap_ctrl_s()<CR>
nnoremap T :tag<CR>

" 交换 ' 和 `，因为 ` 比 ' 常用但太远
nnoremap ' `
nnoremap ` '

" quickfix 跳转
nnoremap <silent> ]q :cn<CR>
nnoremap <silent> [q :cp<CR>

" diagnostic 跳转
nnoremap <silent> ]w :lua vim.diagnostic.goto_next()<CR>
nnoremap <silent> [w :lua vim.diagnostic.goto_prev()<CR>

" 终端模拟器键位绑定
if exists(':tmap')
    " NOTE: 由于终端的转义特性，<Esc> 的识别依赖于延时，所以如果映射了这个按键
    "       的话，会导致鼠标点击的识别出问题，所以，我们不再映射 <Esc> 了
    tnoremap <silent> <C-y><C-y> <C-\><C-n>
    tnoremap <silent> <C-\><C-\> <C-\><C-n>
    if has('nvim')
        func s:SetupTerminal()
            if &buftype !=# 'terminal'
                return
            endif
            setl nolist nonumber cursorline
            "autocmd! WinEnter <buffer> if getpos('.')[1:2] == [line('$'), col('$')] | star | endif
            autocmd! WinEnter <buffer> if getpos('.')[1] == line('$') | star | endif
            " vim 有 BUG, 某些情况下创建新窗口的时候, 会导致意外的进入插入模式
            autocmd! BufLeave <buffer> stopinsert
            startinsert
        endfunc
        command -nargs=* Terminal sp | terminal <args>
        tnoremap <C-\>: <C-\><C-n>:
        tnoremap <C-h> <C-\><C-n><C-w>h
        tnoremap <C-j> <C-\><C-n><C-w>j
        tnoremap <C-k> <C-\><C-n><C-w>k
        tnoremap <C-l> <C-\><C-n><C-w>l
        tnoremap <C-v> <C-\><C-n>"+pa
        autocmd vimrc TermOpen * call s:SetupTerminal()
    else
        command -nargs=* Terminal terminal <args>
        function s:tbs()
            call term_sendkeys(bufnr('%'), "\<C-w>")
        endfunction
        tnoremap <C-\>: <C-w>:
        tnoremap <C-h> <C-w>h
        tnoremap <C-j> <C-w>j
        tnoremap <C-k> <C-w>k
        tnoremap <C-l> <C-w>l
        tnoremap <silent> <C-w> <C-w>:call <SID>tbs()<CR>
        if exists('##TerminalOpen')
            autocmd vimrc TerminalOpen * if &bt ==# 'terminal' | setl nolist nonu wfh | endif
        endif
    endif
endif


if has('nvim')
    nnoremap <silent> \f :Telescope find_files<CR>
    "nnoremap <silent> \e :Telescope command_history<CR>
    " Leaderf 的实现更好用, 因为同样的匹配的时候, 最近的命令更优先
    nnoremap <silent> \e :Leaderf cmdHistory --regexMode<CR>
    nnoremap <silent> \b :Telescope buffers<CR>
    "nnoremap <silent> \t :Telescope current_buffer_tags<CR>
    nnoremap <silent> \t :Leaderf bufTag<CR>
    nnoremap <silent> \T :Telescope tags<CR>
    " gtags => g
    nnoremap <silent> \g :Telescope tags<CR>
    nnoremap <silent> \/ :Telescope current_buffer_fuzzy_find<CR>
else
    nnoremap <silent> \f :Leaderf file<CR>
    nnoremap <silent> \e :Leaderf cmdHistory --regexMode<CR>
    nnoremap <silent> \b :Leaderf buffer<CR>
    nnoremap <silent> \t :Leaderf bufTag<CR>
endif

"=======================================
" 命令行模式，包括搜索时
"=======================================
cnoremap <C-h> <Left>
cnoremap <C-j> <Down>
cnoremap <C-k> <Up>
cnoremap <C-l> <Right>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <C-a> <Home>
cnoremap <C-d> <Del>

"=======================================
" 可视和选择模式
"=======================================
vnoremap <silent> <C-s> <C-c>:update<CR>
"vnoremap y "+y
"vnoremap x "+x
vnoremap $ $h

" 仅选择模式
snoremap <BS> <BS>i

"=======================================
" 可视模式
"=======================================
xnoremap ; :
xnoremap <Space> 3j
xnoremap , 3k
xnoremap ( di()<ESC>Pl
xnoremap [ di[]<ESC>Pl
xnoremap { di{}<ESC>Pl
xnoremap ' di''<ESC>Pl
xnoremap " di""<ESC>Pl

" 选择后立即搜索
xnoremap / y:let @" = substitute(@", '\\', '\\\\', "g")<CR>
    \:let @" = substitute(@", '\/', '\\\/', "g")<CR>/\V<C-r>"<CR>N
" C 文件的 #if 0 段落注释
xnoremap 0 <C-c>:call myrc#MacroComment()<CR>


" ======================================
" 插入模式下
" ======================================
inoremap <silent> <C-s> <ESC>:update<CR>
inoremap <C-o> <End><CR>
" 不能使用 <C-\><C-o>O, 因为可能会导致多余的缩进
inoremap <C-z> <Esc>O
inoremap <silent> <expr> <C-e> myrc#i_CTRL_E()
inoremap <C-a> <Home>
inoremap <C-d> <Del>

" 写 C 时麻烦的宏定义大写问题，解决！
inoremap <silent> <expr> <C-y> pumvisible()?"\<C-y>":"\<C-r>=myrc#ToggleCase()\<CR>"

imap <C-h> <Left>
imap <C-j> <Down>
imap <C-k> <Up>
imap <C-l> <Right>
imap <C-b> <Left>
imap <C-f> <Right>
imap <C-p> <Up>
imap <C-n> <Down>

" ============================================================================
" 插件设置
" ============================================================================
" 激活 bundle 目录的插件, 优先于 Plug
call pathogen#infect()
" 设置 nvim 主题
if has('nvim') "{{{
    " 写成一行, 避免默认的语法解释出现奇怪的问题
    silent! lua require('gruvbox').setup({bold=true, italic={strings=false, emphasis=false, comments=false, operators=false, folds=false},
        \ terminal_colors=vim.fn.has('gui_running')==1})
endif
"}}}

" ========== tagbar ==========
"{{{
let g:tagbar_compact = 1
let g:tagbar_width = 30
let g:tagbar_sort = 0
"let g:tagbar_expand = 1
let g:tagbar_map_showproto = 'S'
let g:tagbar_silent = 1
let g:tagbar_disable_statusline = v:true
if has("win32") || has("win64")
    if !executable('ctags')
        let g:tagbar_ctags_bin = $VIM . '\vimfiles\bin\ctags.exe'
    endif
endif

let g:tagbar_type_rfc = {
    \ 'ctagstype' : 'rfc',
    \ 'kinds'     : [
        \ 'c:chapters',
    \ ],
    \ 'sort'    : 0,
    \ 'deffile' : s:joinpath(s:USERRUNTIME, 'ctags', 'rfc.cnf'),
\ }

let g:tagbar_type_autoit = {
    \ 'ctagstype' : 'autoit',
    \ 'kinds'     : [
        \ 'f:functions',
    \ ],
    \ 'sort'    : 0,
    \ 'deffile' : s:joinpath(s:USERRUNTIME, 'ctags', 'autoit.cnf'),
\ }

if s:IsWindowsOS()
    let g:tagbar_type_markdown = {
        \ 'ctagstype' : 'markdown',
        \ 'kinds' : [
            \ 'h:headings',
        \ ],
        \ 'sort' : 0,
        \ 'deffile' : s:joinpath(s:USERRUNTIME, 'ctags', 'markdown.cnf'),
    \ }
endif

let g:tagbar_type_cpp = {
    \ 'ctagstype' : 'c++',
    \ 'kinds'     : [
        \ 'd:macros:0',
        \ 'p:prototypes:1',
        \ 'g:enums',
        \ 'e:enumerators',
        \ 't:typedefs',
        \ 'n:namespaces',
        \ 'c:classes',
        \ 's:structs',
        \ 'u:unions',
        \ 'f:functions',
        \ 'm:members',
        \ 'v:variables'
    \ ],
    \ 'sro'        : '::',
    \ 'kind2scope' : {
        \ 'g' : 'enum',
        \ 'n' : 'namespace',
        \ 'c' : 'class',
        \ 's' : 'struct',
        \ 'u' : 'union'
    \ },
    \ 'scope2kind' : {
        \ 'enum'      : 'g',
        \ 'namespace' : 'n',
        \ 'class'     : 'c',
        \ 'struct'    : 's',
        \ 'union'     : 'u'
    \ }
\ }

" 修正 go 文件类型无法显示结构体成员的问题
let g:tagbar_type_go = {
    \ 'ctagstype' : 'go',
    \ 'kinds'     : [
        \ 'p:packages:0:0',
        \ 'i:interfaces:0:0',
        \ 'c:constants:0:0',
        \ 's:structs:0:1',
        \ 'm:struct members:0:0',
        \ 't:types:0:1',
        \ 'f:functions:0:1',
        \ 'v:variables:0:0',
        \ 'a:talias:0:0',
    \ ],
    \ 'sro' : '.',
    \ 'kind2scope' : {
        \ 's' : 'struct',
        \ 'p' : 'package',
    \ },
    \ 'scope2kind' : {
        \ 'struct'  : 's',
        \ 'package' : 'p',
    \ }
\ }

nnoremap <nowait> <Leader>t :TagbarToggle<CR>
nnoremap <nowait> <Leader>f :NvimTreeToggle<CR>

"}}}
" ========== NERDTree ==========
"{{{
" 设置不显示的文件，效果为仅显示 .c,.cpp,.h 文件，无后缀名文件暂时无法解决
"let NERDTreeIgnore = ['\(\.cpp$\|\.c$\|\.h$\|\.cxx\|\.hpp\)\@!\..\+', '\~$']
let NERDTreeIgnore = ['^__pycache__$[[dir]]']
let NERDTreeMapMenu = "."
if g:OnlyASCII()
    let NERDTreeDirArrowExpandable = '+'
    let NERDTreeDirArrowCollapsible = '~'
endif
let NERDTreeMinimalUI = 1
let NERDTreeStatusline = -1
"}}}
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
xmap <silent> <C-n> <plug>NERDCommenterToggle
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
nmap <silent> \\ <Plug>MarkSet
xmap <silent> \\ <Plug>MarkSet
nmap <silent> \c :noh<CR><Plug>MarkAllClear
nmap <silent> * <Plug>MarkSearchCurrentNext
nmap <silent> # <Plug>MarkSearchCurrentPrev
nmap <silent> <Leader>* <Plug>MarkSearchNext
nmap <silent> <Leader># <Plug>MarkSearchPrev
nnoremap <silent> <2-LeftMouse> :call <SID>MouseMark()<CR>
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

" 括号自动补全. 为了性能, 直接禁用闭合检查
" 仅 vim 适用, nvim 使用 ultimate-autopair.nvim 插件实现
if !has('nvim')
    inoremap ( ()<Left>
    inoremap [ []<Left>
    inoremap { {}<Left>
    inoremap <expr> " (&filetype == "vim") ? "\"" : "\"\"\<Left>"
    inoremap <expr> ' (&ft ==# 'lisp') ? "'" : "''\<Left>"
endif

"cnoremap ( ()<Left>
"cnoremap [ []<Left>
"cnoremap { {}<Left>
"cnoremap " ""<Left>
cnoremap <expr> <BS> <SID>c_BS_plus()

inoremap <expr> <BS> <SID>i_BS_plus()
inoremap <expr> ; <SID>i_Semicolon_plus()
inoremap <C-g> <C-r>=myrc#i_InsertHGuard()<CR>

" 补全模式下的映射
inoremap <silent> <CR> <C-r>=myrc#SmartEnter()<CR>

function! s:i_Semicolon_plus() "{{{
    let sLine = getline('.')
    if sLine !~# '^\s*for\>' && sLine[col('.') - 1] ==# ')'
        return "\<Right>;"
    else
        return ";"
    endif
endfunction
"}}}
function! IfPair(char1,char2) "{{{
    " 命令行模式
    if mode() =~# '^c'
        if getcmdline()[getcmdpos() - 2] == a:char1 && getcmdline()[getcmdpos() - 1] == a:char2
            return 1
        else
            return 0
        endif
    endif

    if getline('.')[col('.') - 2] == a:char1 && getline('.')[col('.') - 1] == a:char2
        return 1
    else
        return 0
    endif
endfunction
"}}}
function! s:i_BS_plus() "{{{
    if IfPair('(',')') || IfPair('[',']') || IfPair('{', '}')
        return "\<DEL>\<BS>"
    else
        return "\<BS>"
    endif
endfunction
"}}}
function! s:c_BS_plus() "{{{
    if IfPair('(',')') || IfPair('[',']') || IfPair('{', '}')
        return "\<DEL>\<BS>"
    else
        return "\<BS>"
    endif
endfunction
"}}}

" ========== cscope 设置 ==========
"{{{
let s:cmd = 'cs'
command -complete=file -nargs=+ CsFind call myrc#CscopeFind(<q-args>)
if has('cscope') " nvim-0.9.0 弃用了 cscope 集成, 需要改为插件式支持
    set cscopeverbose
    set cscopetagorder=1 " cscope 对定义的跳转不够准确, 优先使用 tags 的
    set cscopetag
    set cscopequickfix=s-,c-,d-,i-,t-,e-,a-
    "nnoremap <silent> <C-\>a :call myrc#AlterSource()<CR>
    command! -complete=file -nargs=1 CsAdd call myrc#CscopeAdd(<f-args>)
else
    let s:cmd = 'Cs'
    nnoremap <silent> <C-]> :call myrc#Cstag()<CR>
endif
" cscope_maps 插件
exec printf('nnoremap <silent> <C-\>s :%s find s <C-R>=fnameescape(expand("<cword>"))<CR><CR>', s:cmd)
exec printf('nnoremap <silent> <C-\>g :%s find g <C-R>=fnameescape(expand("<cword>"))<CR><CR>', s:cmd)
exec printf('nnoremap <silent> <C-\>c :%s find c <C-R>=fnameescape(expand("<cword>"))<CR><CR>', s:cmd)
exec printf('nnoremap <silent> <C-\>t :%s find t <C-R>=fnameescape(expand("<cword>"))<CR><CR>', s:cmd)
exec printf('nnoremap <silent> <C-\>e :%s find e <C-R>=fnameescape(expand("<cword>"))<CR><CR>', s:cmd)
exec printf('nnoremap <silent> <C-\>f :%s find f <C-R>=fnameescape(expand("<cfile>"))<CR><CR>', s:cmd)
exec printf('nnoremap <silent> <C-\>i :%s find i ^<C-R>=fnameescape(expand("<cfile>"))<CR>$<CR>', s:cmd)
exec printf('nnoremap <silent> <C-\>d :%s find d <C-R>=fnameescape(expand("<cword>"))<CR><CR>', s:cmd)
exec printf('nnoremap <silent> <C-\>a :%s find a <C-R>=fnameescape(expand("<cword>"))<CR><CR>', s:cmd)
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

" ssh 环境下, 使用 OSC52 剪切板机制, 仅支持某些终端模拟器
Plug 'ojroques/vim-oscyank', {'on': 'OSCYankVisual'}
command! -nargs=0 EnableOSCYank call myrc#enable_oscyank()
command! -nargs=0 DisableOSCYank call myrc#disable_oscyank()
if !empty($SSH_TTY)
    autocmd InsertLeave * silent call myrc#OSCYank('toEnIM()')
endif

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
Plug 'mhinz/vim-startify', {'on': 'Startify'}
Plug 'kassio/neoterm', {'on': 'Tnew'}
Plug 'epheien/nerdtree', {'on': 'NERDTree'} " orig: 'preservim/nerdtree'
Plug 'preservim/nerdcommenter', {'on': '<Plug>NERDCommenterToggle'}
Plug 'epheien/tagbar', {'on': 'TagbarToggle'}
Plug 'epheien/vim-clang-format', {'on': 'ClangFormat'}
" 自己的插件
Plug 'epheien/termdbg', {'on': 'Termdbg'}
Plug 'epheien/videm', {'on': 'VidemOpen'}

" 处理 kitty 背景问题
" NOTE: 为了避免无谓的闪烁, 把终端的背景色设置为和 vim/nvim 一致即可
"if $TERM_PROGRAM =~# '\V\<Apple_Terminal\|\<kitty\|\<alacritty'
if $TERM_PROGRAM =~# '\V\<Apple_Terminal'
    Plug 'epheien/bg.nvim'
endif

if !g:OnlyASCII()
    "Plug 'Xuyuanp/nerdtree-git-plugin'
    "Plug 'ryanoasis/vim-devicons'
endif

" nvim 专用插件
" 管理原则:
"   - Plug 插件能实现懒加载的就用 Plug 管理
"   - 无条件加载的插件也用 Plug 管理
"   - 其他插件就用 pckr.nvim 管理
if has('nvim')
    " 基础配色, 但不在这里加载, 因为时机有点晚
    Plug 'epheien/gruvbox.nvim', {'on': '<Plug>(gruvbox-placeholder)'}
else
" vim 专用插件
    Plug 'posva/vim-vue'
    " vim-which-key 基本不适用于 nvim 了, 因为解析 map 的时候会出错
    Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!'] }
    Plug 'airblade/vim-gitgutter', {'on': 'GitGutterEnable'}
    Plug 'jreybert/vimagit', {'on': 'Magit'}
    Plug 'lambdalisue/gina.vim', {'on': 'Gina'}

    " git 相关插件
    Plug 'junegunn/gv.vim', {'on': 'GV'}
    Plug 'tpope/vim-fugitive', {'on': 'Git'}

    call s:Plug('vim-signature') " TODO
    call s:Plug('json5', {'for': 'json5'})
endif

" 本地插件
call s:Plug('common')
call s:Plug('vim-repeat') " autoload
call s:Plug('mymark', {'on': ['<Plug>MarkSet', '<Plug>MarkAllClear']})
call s:Plug('python-syntax', {'for': 'python'})
call s:Plug('jsonfmt', {'on': 'JsonFmt'})
call s:Plug('colorizer', {'on': 'UpdateColor'})
call s:Plug('colorsel', {'on': 'ColorSel'})
call s:Plug('visincr', {'on': 'I'})

" 代码补全相关插件
"Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'skywind3000/vim-auto-popmenu', {'on': 'ApcEnable'}
if has('nvim')
    "Plug 'neoclide/coc.nvim', {'branch': 'release', 'on': 'CocStart'}
    "Plug 'Shougo/neosnippet.vim'
    "Plug 'Shougo/neosnippet-snippets'
else
    let g:apc_enable_tab = 0
    let g:apc_enable_ft = {'*': 1}
endif

call plug#end()
" ####

" ========== Plug 安装的插件的配置，理论上不应过长 ==========
"let g:gruvbox_contrast_dark = 'hard'
let g:gruvbox_italic = 0 " gruvbox 主题的斜体设置, 中文无法显示斜体, 所以不用
if !has('nvim')
    let g:gruvbox_bold = 0 " gruvbox 主题的粗体设置
endif
let g:mkdp_auto_close = 0 " markdown-preview 禁止自动关闭
let g:asyncrun_open = 5 " asyncrun 自动打开 quickfix

if has('nvim')
    autocmd vimrc VimEnter * ++once set helplang=
endif

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
if has('nvim')
    let g:Lf_WindowPosition = 'popup'
    "autocmd vimrc filetype * if &ft == 'leaderf' | setl nonumber | endif
endif

" NOTE: g:plugs 是 plug.vim 插件导出的变量, 但是没有文档, 看源码得出的
if has_key(g:plugs, 'lightline.vim') | call s:setup_lightline() | endif
" 稍微定制一下 startify 的 header
let g:startify_custom_header = [
    \ '        __________       ______ ___                  _____            ',
    \ '        ___  ____/__________  /__( )_______   ___   ____(_)______ ___ ',
    \ '        __  __/  ___  __ \_  __ \|/__  ___/   __ | / /_  /__  __ `__ \',
    \ '        _  /___  __  /_/ /  / / /  _(__  )    __ |/ /_  / _  / / / / /',
    \ '        /_____/  _  .___//_/ /_/   /____/     _____/ /_/  /_/ /_/ /_/ ',
    \ '                 /_/                                                  ',
    \ ]

if has('nvim') && $TERM_PROGRAM !=# 'Apple_Terminal'
    set termguicolors | call s:SetupColorscheme('gruvbox')
else
    call s:SetupColorscheme('gruvbox-origin')
endif

if exists(':Rg') != 2
    command! -nargs=+ -complete=customlist,myrc#FileComplete Rg call myrc#rg(<q-args>)
endif

" vim-go
let g:go_gopls_enabled = 1
let g:go_version_warning = 0
let g:go_fmt_autosave = 0
let g:go_imports_autosave = 0
let g:go_fmt_experimental = 1
let g:go_term_enabled = 1
let g:go_term_mode = "split"
let g:go_diagnostics_enabled = 0
let g:go_highlight_diagnostic_errors = 0
let g:go_metalinter_enabled = ['errcheck']
" 高亮色以 :h group-name 为指导
" 高亮函数声明
let g:go_highlight_functions = 1
" 高亮函数调用
let g:go_highlight_function_calls = 1
hi link goFunctionCall Function
" 高亮 x := 的 x
let g:go_highlight_variable_declarations = 1
hi link goVarDefs Identifier
" GoDoc 使用 floating window
let g:go_doc_popup_window = 1
let g:go_debug_log_output = ''
let g:go_def_mapping_enabled = 0

" gutentags
if has('nvim') || has('cscope')
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
endif

" ==========================================================
" 自己的简易插件
" ==========================================================
" ========== SimpleSuperTab ==========
"{{{
" 需要把 completeopt 设置为 menuone
inoremap <silent> <Tab> <C-r>=myrc#SuperTab()<CR>
inoremap <silent> <S-Tab> <C-r>=myrc#ShiftTab()<CR>

"}}}
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
" Show hover when provider exists, fallback to vim's builtin behavior.
nnoremap <silent> K :call <SID>ShowDocumentation()<CR>
function! s:ShowDocumentation()
    if has('nvim-0.10') && luaeval('#vim.lsp.get_clients({bufnr=vim.fn.bufnr()})') > 0
        lua vim.lsp.buf.hover()
    elseif exists('g:did_coc_loaded') && CocAction('hasProvider', 'hover')
        call CocActionAsync('definitionHover')
    else
        call feedkeys('K', 'in')
    endif
endfunction
" ========== smartim by hammerspoon ==========
"{{{
if has('mac')
    function! s:job_start(cmd)
        if has('nvim')
            return jobstart(a:cmd)
        else
            return job_start(a:cmd)
        endif
    endfunction
    " 可使用 system 来同步, 只要 hammerspoon 足够快就没问题
    augroup smartim
        autocmd!
        " NOTE: 这个 VimEnter 事件比较耗时, 但是为了使用方便, 还是要用
        autocmd VimEnter    * call s:job_start('open -g hammerspoon://toEnIM')
        autocmd VimLeavePre * call s:job_start('open -g hammerspoon://toEnIM')
        autocmd InsertLeave * call s:job_start('open -g hammerspoon://toEnIM')
        autocmd FocusGained * call s:job_start('open -g hammerspoon://toEnIM')
    augroup end
endif
"}}}

" ========== videm ==========
" videm 的一些扩展
" ## gtags
command VGtagsInit call myrc#VGtagsInit()

" ========== termdbg ==========
nnoremap <silent> <C-p> :exec 'TSendCommand p' expand('<cword>')<CR>
vnoremap <silent> <C-p> y:exec 'TSendCommand p' @"<CR>
" 参考 magic keyboard 的媒体按键, F8 暂停用于 step, F9 下一曲用于 next
nnoremap <silent> <F9> :TNext<CR>
nnoremap <silent> <F8> :TStep<CR>
" 快捷键来自 vscode 的调试器
nnoremap <silent> <F10> :TNext<CR>
nnoremap <silent> <F11> :TStep<CR>

" ========== mydict ==========
nnoremap <silent> <C-f> :call mydict#Search(expand('<cword>'))<CR>
vnoremap <silent> <C-f> y:call mydict#Search(@")<CR>
command! -nargs=+ Dict call mydict#Search(<q-args>)

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

" 使用 gonvim 的时候, 通过外挂的形式改变窗口的尺寸
if get(g:, 'gonvim_running', 0)
    let g:line_ppp = 14
    let g:column_ppp = 8
    autocmd OptionSet * call myrc#optionset_hook()
endif

" macOS 下, neovide 和 alacritty 在中文输入法下强制输入全角标点符号,
" 但好消息是可以用映射修正这个问题
if has('mac') || exists('$SSH_TTY')
    let keymaps = {
        \   '，': ',',
        \   '；': ';',
        \   '。': '.',
        \   '：': ':',
        \   '？': '?',
        \   '！': '!',
        \   '【': '[',
        \   '】': ']',
        \   '（': '(',
        \   '）': ')',
        \   '·': '`',
        \}
    for [lhs, rhs] in items(keymaps)
        exec 'imap' lhs rhs
        exec 'tmap' lhs rhs
    endfor
endif

" ----------------------------------------------------------------------------
" vim: fdm=marker fen fdl=0 sw=4 sts=-1 et
