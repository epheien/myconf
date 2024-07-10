" ============================================================================
" 用于 MANPAGER 的基础配置，目的是为了加快启动速度
" ============================================================================

function s:IsWindowsOS() "{{{
    return has("win32") || has("win64")
endfunction
"}}}
function s:IsLinuxOS() "{{{
    return !s:IsWindowsOS()
endfunction
"}}}

" 关闭 vi 兼容模式，否则无法使用 vim 的大部分扩展功能
set nocompatible
" 让退格键以现代化的方式工作
set backspace=2
" 设置 Vim 内部使用的字符编码
set encoding=utf-8

" 禁用菜单栏等，不放在 .gvimrc 以避免启动时晃动
"set guioptions+=M
"set guioptions-=m
set guioptions-=t
set winaltkeys=no

" 交换文件不放到跟编辑的文件同一个目录
set directory-=.

" 自动缩进设置
" 使新行缩进与前一行一样
set autoindent
" 主要是实现自动对齐大括号的缩进
set smartindent
" 打开 cindent，主要体现为函数参数过长时，换行自动缩进
set cindent
set cinoptions+=(0,W8

" 在 vim 窗口右下角，标尺的右边显示未完成的命令
set showcmd

" 左下角显示当前模式
set showmode

" 语法高亮
syntax on

" 文件类型的检测
" 为特定的文件类型允许插件文件的载入
" 为特定的文件类型载入缩进文件
filetype plugin indent on


" 禁用响铃
"set noerrorbells
" 禁用闪屏
"set vb t_vb=

" 显示行号
set nonumber

" 设定文件编码类型，彻底解决中文编码问题
let &termencoding=&encoding
"set fileencodings=utf-8,gbk,gb18030,utf-16,ucs-bom,cp936

" 设置搜索结果高亮显示
set hlsearch
" 搜索时忽略大小写
set ignorecase
set smartcase
" 在搜索模式时输入时即时显示相应的匹配点。
set incsearch

" 设置不自动备份
set nobackup
" 保留原始文件
"set patchmode=.orig

" 启动对鼠标的支持
set mouse=a

" 第一行设置tab键为4个空格，第二行设置当行之间交错时使用4个空格
"set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

" 长行不能完全显示时显示当前屏幕能显示的部分，长行不能完全显示时显示 @
set display=lastline

set laststatus=0

" 上下为跨屏幕一行
noremap <silent> k gk
noremap <silent> j gj

" 自动绕行显示
set wrap
" 按词绕行
"set linebreak
" 回绕行的前导符号
"set showbreak=<-->
" 光标上下需要保留的行数，滚动时用
set scrolloff=3

" 设置鼠标和选择的行为
set selectmode=key
set mousemodel=popup
set keymodel=startsel,stopsel
set selection=inclusive
if s:IsLinuxOS()
    " 修正鼠标右键菜单行为
    noremap <RightMouse> <Nop>
    noremap <RightRelease> <RightMouse>
    noremap! <RightMouse> <Nop>
    noremap! <RightRelease> <RightMouse>
    " 没用的 3、4 连击
    noremap <3-LeftMouse> <Nop>
    noremap! <3-LeftMouse> <Nop>
    noremap <4-LeftMouse> <Nop>
    noremap! <4-LeftMouse> <Nop>
endif
" 我的鼠标的中键坏了，禁用掉这个功能，以免改错文件
noremap <MiddleMouse> <Nop>
noremap <2-MiddleMouse> <Nop>
noremap <3-MiddleMouse> <Nop>
noremap <4-MiddleMouse> <Nop>
inoremap <MiddleMouse> <Nop>
inoremap <2-MiddleMouse> <Nop>
inoremap <3-MiddleMouse> <Nop>
inoremap <4-MiddleMouse> <Nop>

" 全能补全禁止预览
"set completeopt=longest,menu
"set completeopt=menuone,preview
set completeopt=menuone
try
    " 暂时不知道具体到什么版本才支持这个选项
    set completeopt+=noinsert
catch /.*/
endtry
" 补全窗口不用太大, 限制之
set pumheight=5

" 显示水平滚动条
"set guioptions+=b

" 修改<Leader>键，默认为 '\'
" 重新映射的原因是，很多插件擅自映射了复杂的<Leader>绑定，导致自用的绑定不灵敏
"let mapleader = "\\"
let mapleader = "\<F12>"

" 代码自动折叠设置
set foldenable     " 打开代码折叠
"set nofoldenable   " 关闭代码折叠
" 代码折叠，根据语法
"set foldmethod=syntax
" 代码折叠，手动
set foldmethod=manual
" 设置折叠级别: 高于此级别的折叠会被关闭
set foldlevel=9999

" 允许光标移动到刚刚超过行尾字符之后的位置
set virtualedit=onemore,block

" 标签页显示。0:1:2 = 总是不显示:超过一个才显示:总是显示
"set showtabline=2

" 自动完成扫描的文件
" 缺省 ".,w,b,u,t,i"
" 当前缓冲区，其他窗口的buf，其他载入的buf，卸载的buf，标签，头文件
"set complete=.,w,b,u,t,i
"set complete=.,t,i
set complete=.,t,w,b,k

" 注意: 打开次选项会使得某些插件无法工作。
"set autochdir

" 切换时隐藏缓冲而不是提示已修改未保存
set hidden

" 设置 session 文件保存的信息
" (缺省: "blank,buffers,curdir,folds,help,options,tabpages,winsize")
set sessionoptions=buffers,curdir,folds,help,localoptions,tabpages,winsize,resize

set background=dark
" 颜色方案
if has('gui_running')   " gui 的情况下
    if has('nvim')
        colorscheme gruvbox-origin
    else
        colorscheme desertex
    endif
elseif &t_Co == 256     " 支持 256 色的话
    if has('nvim')
        colorscheme gruvbox-origin
    else
        colorscheme desertex
    endif
elseif $TERM ==# "xterm"
    colorscheme default
else
    colorscheme default
endif

" 增强的命令行补全
set wildmenu

" 执行宏、寄存器和其它不通过输入的命令时屏幕不会重画
"set lazyredraw

" 设置键码延时, 避免终端下 <ESC> 的等待
set ttimeoutlen=50

" 用空格来显示制表并同时把光标放在空白开始位置
set list listchars=tab:\ \ 

" 删除环境变量 LANGUAGE，不然会影响某些插件无法提取英文环境下的命令输出
"let $LANGUAGE=''

" ============================================================================
" 常规键盘映射
" ============================================================================
" 最常用的复制粘贴
if has('clipboard')
    vnoremap <C-x> "+x
    vnoremap <C-c> "+y
    vnoremap <C-v> "+gP
    nnoremap <C-v> "+gP
    inoremap <C-v> <C-r>+
    cnoremap <C-v> <C-r>+
    if exists(':tmap')
        tnoremap <C-v> <C-w>"+
    endif
else
    vnoremap <silent> <C-x> ""x:call myrc#cby()<CR>
    vnoremap <silent> <C-c> ""y:call myrc#cby()<CR>
    vnoremap <silent> <C-v> "_d:<C-u>call myrc#cbp()<CR>""gP
    nnoremap <silent> <C-v> :call myrc#cbp()<CR>""gP
    inoremap <silent> <C-v> <C-r>=myrc#cbp()<CR><C-r>"
    cnoremap <silent> <C-v> <C-r>=myrc#cbp()<CR><C-r>=myrc#_paste()<CR>
    if exists(':tmap')
        tnoremap <silent> <C-v> <C-w>:call myrc#cbp()<CR><C-w>""
    endif
endif

" ======================================
" 普通模式
" ======================================
function! s:n_BufferDelete() "{{{
    let curb = bufnr('%')
    bNext
    exec "bd " . curb
    if exists("*BufExplorer_Fix")
        call BufExplorer_Fix()
    endif
endfunction
"}}}
nnoremap <silent> \- :set columns-=30<CR>
nnoremap <silent> \= :set columns+=30<CR>
nnoremap <silent> \l :%s/\r//g<CR>
nnoremap <silent> \d :call <SID>n_BufferDelete()<CR>
nnoremap \h :cd %:p:h <Bar> pwd<CR>
nnoremap \] :mksession! vimp.vim <Bar> wviminfo! vimp.vi<CR>
nnoremap <Space> 3<C-e>
nnoremap <S-Space> 3<C-y>
nnoremap , 3<C-y>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
if exists(':tmap')
    function s:tbs()
        call term_sendkeys(bufnr('%'), "\<C-w>")
    endfunction
    tnoremap <C-\>: <C-w>:
    tnoremap <C-h> <C-w>h
    tnoremap <C-j> <C-w>j
    tnoremap <C-k> <C-w>k
    tnoremap <C-l> <C-w>l
    tnoremap <C-v> <C-w>"+
    tnoremap <silent> <C-BS> <C-w>:call <SID>tbs()<CR>
    tnoremap <silent> <C-w> <C-w>:call <SID>tbs()<CR>
endif
nnoremap ; :
nmap <silent> gq q
"nnoremap <C-a> ggVG
nnoremap <C-Tab> :bnext<CR>
nnoremap <S-Tab> :bNext<CR>
" stty -ixon
nnoremap <silent> <C-s> :update<CR>
"nnoremap <CR> <C-w>}
nnoremap <C-p> <C-w>z
nnoremap T :tag<CR>
"nnoremap <C-z> u
if has('gui_running')
    nnoremap <C-v> "+gP
endif

" 交换 ' 和 `，因为 ` 比 ' 常用但太远
nnoremap ' `
nnoremap ` '

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
cnoremap <C-BS> <C-w>
cnoremap <C-d> <Del>
if has('gui_running')
    cnoremap <C-v> <C-r>+
endif

"=======================================
" 可视和选择模式
"=======================================
if has('gui_running')
    vnoremap <C-x> "+x
    vnoremap <C-c> "+y
    vnoremap <C-v> "+gP
endif
vnoremap <silent> <C-s> <C-c>:update<CR>
"vnoremap y "+y
"vnoremap x "+x

"=======================================
" 可视模式
"=======================================
xnoremap <Space> 3j
xnoremap , 3k

" 选择后立即搜索
xnoremap / y:let @" = substitute(@", '\\', '\\\\', "g")<CR>
    \:let @" = substitute(@", '\/', '\\\/', "g")<CR>/\V<C-r>"<CR>N
" C 文件的 #if 0 段落注释

" 添加字典插件
nnoremap <silent> <C-f> :call mydict#Search(expand('<cword>'))<CR>
vnoremap <silent> <C-f> y:call mydict#Search(@")<CR>

" ----------------------------------------------------------------------------
" vim: fdm=marker fen fdl=0 expandtab softtabstop=4
