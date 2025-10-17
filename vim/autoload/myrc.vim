" 用于 vimrc 的懒加载函数

if exists('s:loaded')
    finish
endif
let s:loaded = 1
let s:gtags_files_dict = {}
let s:enable_oscyank = v:false

" 初始化本脚本的依赖项
function! s:init() abort
    if get(g:, 'colors_name', '') =~# '^catppuccin'
        return
    endif
    " tabline 高亮, gruvbox 主题
    "hi! MyTabLineSel    ctermfg=235 ctermbg=246 guifg=#282828 guibg=#a89984
    "hi! MyTabLineNotSel ctermfg=246 ctermbg=239 guifg=#a89984 guibg=#504945
    "hi! MyTabLineFill   ctermbg=237 guibg=#3c3836 " 原版是 235 #282828
    "hi! MyTabLineClose  ctermfg=235 ctermbg=208 guifg=#282828 guibg=#fe8019

    " mywombat 主题
    hi! MyTabLineSel    ctermfg=238 ctermbg=117 guifg=#444444 guibg=#8ac6f2
    hi! MyTabLineNotSel ctermfg=247 ctermbg=240 guifg=#969696 guibg=#585858
    hi! MyTabLineFill   ctermfg=240 ctermbg=238 guifg=#585858 guibg=#444444
    hi! MyTabLineClose  ctermfg=248 ctermbg=242 guifg=#a8a8a8 guibg=#666666
endfunction

call s:init()

" 副本函数，为了懒加载，容许一定量的副本函数
function s:IsWindowsOS()
    return has("win32") || has("win64")
endfunction
function s:IsUnixOS()
    return has('unix')
endfunction
function s:IsLinuxOS()
    return !s:IsWindowsOS()
endfunction
function s:IsMacOS()
    return has('mac')
endfunction

function s:joinpath(...)
    let sep = '/'
    if s:IsWindowsOS()
        let sep = '\'
    endif
    return join(a:000, sep)
endfunction

function myrc#echow(...)
    if empty(a:000)
        return
    endif
    echohl WarningMsg
    echomsg join(a:000, ' ')
    echohl None
endfunction

function myrc#VGtagsInit() abort
    if !exists('*Videm_GetAllFiles')
        call myrc#echow('videm not ready')
        return
    endif
    if &cscopeprg !~# '\<gtags-cscope\>'
        if !executable('gtags-cscope')
            call myrc#echow('gtags-cscope not found')
            return
        endif
        set cscopeprg=gtags-cscope
    endif
    let l:gtags_files = Videm_GetAllFiles(1)
    let cwd = Videm_GetWorkspaceDirectory()
    if writefile(l:gtags_files, s:joinpath(cwd, 'gtags.files'))
        call myrc#echow('Failed to write gtags.files')
        return
    endif
    let s:gtags_files_dict = {}
    for file in l:gtags_files
        let s:gtags_files_dict[s:realpath(file)] = 1
    endfor
    let dict = {'cwd': getcwd()}
    function! s:exit_cb(job, code) dict
        if a:code
            call myrc#echow('gtags return', a:code)
            return
        endif
        call myrc#CscopeAdd(s:joinpath(self.cwd, 'GTAGS'), 0)
    endfunction
    " DEBUG
    function! s:output_cb(chan, msg)
        "echomsg string(a:msg)
    endfunction
    let prg = exepath(substitute(&cscopeprg, '-cscope\>', '', ''))
    let options = {}
    if has('nvim')
        " TODO: nvim
    else
        let options['exit_cb'] = function('s:exit_cb', [], dict)
        let options['err_io'] = 'out'
        let options['out_cb'] = function('s:output_cb')
        let s:gtags_job = job_start([prg], options)
    endif
endfunction

function myrc#UpdateGtags(fname)
    if !cscope_connection(1, 'GTAGS')
        return
    endif
    let fname = s:realpath(a:fname)
    let prepath = get(s:gtags_files_dict, fname, '')
    if empty(prepath)
        return
    endif
    " "cd %s && %s -f %s --single-update %s"
    let prg = exepath(substitute(&cscopeprg, '-cscope\>', '', ''))
    let cmd = [prg, '--single-update', fname]
    if has('nvim')
        let s:gtags_job = jobstart(cmd, {'cwd': prepath})
    else
        let s:gtags_job = job_start(cmd, {'cwd': prepath})
    endif
endfunction

" cscope 的场合，直接添加就不管了
" gtags 的场合，以 gtags.files 为基准，作增量更新
" gtags 的增量更新包括：添加文件，更新文件，删除文件
" 本函数只支持 gtags 的“更新文件”情况下的增量更新
" (name, refresh_gtags_files=1)
function! myrc#CscopeAdd(name, ...) abort
    let prepath = fnamemodify(a:name, ':p:h')
    " &cscopeprg 默认为 'cscope'
    if a:name =~# '\<GTAGS$'
        if !executable('gtags-cscope')
            call myrc#echow('gtags-cscope not found')
            return
        endif
        if &cscopeprg !~# '\<gtags-cscope\>'
            silent cscope kill -1
            set cscopeprg=gtags-cscope
        endif
    elseif a:name =~? 'cscope'
        if !executable('cscope')
            return
        endif
        if &cscopeprg =~# '\<gtags\>'
            silent cscope kill -1
            set cscopeprg=cscope
        endif
    else
        return
    endif
    let save_csverb = &cscopeverbose
    set cscopeverbose
    "exec printf('silent! cscope kill %s %s', fnameescape(a:name), fnameescape(prepath))
    if a:name =~# '\<GTAGS$'
        " NOTE: 添加 GTAGS 的时候，只能添加当前目录下的 GTAGS
        let flag = 0
        if getcwd() !=# prepath
            let flag = 1
            exec 'silent' 'cd' fnameescape(prepath)
        endif
        try
            exec printf('cscope add %s %s', 'GTAGS', fnameescape(prepath))
        finally
            if flag
                silent cd -
            endif
        endtry
    else
        exec printf('cscope add %s %s', fnameescape(a:name), fnameescape(prepath))
    endif
    let &cscopeverbose = save_csverb
    if &cscopeprg =~# '\<gtags-cscope\>' && filereadable(s:joinpath(prepath, 'gtags.files'))
        let refresh_gtags_files = get(a:000, 0, 1)
        if refresh_gtags_files
            exec 'silent' 'cd' fnameescape(prepath)
            try
                " NOTE: 不能处理编码，一般来说，utf-8 编码的话一般不出问题
                let gtags_files = readfile(s:joinpath(prepath, 'gtags.files'))
                call filter(s:gtags_files_dict, 0)
                for file in gtags_files
                    let s:gtags_files_dict[s:realpath(file)] = prepath
                endfor
            finally
                silent cd -
            endtry
        endif
        augroup myrc_gtags
            autocmd!
            autocmd! BufWritePost * call myrc#UpdateGtags(expand('%:p'))
        augroup END
    endif
endfunction

function! myrc#CscopeFind(args) abort
    if has('cscope')
        exec 'cs find' a:args
    else
        exec 'Cs find' a:args
    endif
endfunction

function! myrc#AlterSource()
    let l:file = expand("%:t:r")
    let l:ext = expand("%:t:e")
    if l:ext == "c" || l:ext == "cpp"
        try
            exec 'cs find f \<' . l:file . ".h$"
        catch
            try
                exec 'cs find f \<' . l:file . ".hpp$"
            catch
                return
            endtry
            return
        endtry
    elseif l:ext == "h" || l:ext == "hpp"
        try
            exec 'cs find f \<' . l:file . ".c$"
        catch
            try
                exec 'cs find f \<' . l:file . ".cpp$"
            catch
                return
            endtry
            return
        endtry
    endif
endfunction

" 简单的 rg 调用封装，固定添加 --vimgrep 参数
function! myrc#rg(qargs) abort
    if !exists('*asyncrun#run')
        try
            exec 'AsyncRun'
        catch
        endtry
    endif
    call asyncrun#run(0, '', 'rg --vimgrep ' . a:qargs)
    botright copen
endfunction

" ========== 在预览窗口显示标签内容 ==========
"nnoremap <silent> <CR> :call PreviewWord()<CR>
function! PreviewWord() "{{{2
    " quickfix窗口和命令窗口不映射
    if &ft ==# 'qf' ||
            \ (bufname('%') ==# '[Command Line]' && &buftype ==# 'nofile')
        exec "normal! \<CR>"
        return
    endif

    if &previewwindow
        let flag = 1
    else
        let flag = 0
    endif

    let orgbuf = bufnr('%')
    let w = expand("<cword>")       " 在当前光标位置抓词
    if w =~ '\a'                    " 如果该单词包括一个字母
        let l:bak_shm = &shm
        let l:bak_ei = &ei
        set eventignore+=BufEnter,WinEnter,BufWinEnter "TODO: 需要更好的方案
        set shortmess+=A

        if &filetype == "help"
            exec "normal! \<C-w>}"
        else
            try
                exec "ptag " . w
            catch
                let &shm = l:bak_shm
                let &ei = l:bak_ei
                return
            endtry
        endif

        let &shm = l:bak_shm
        let &ei = l:bak_ei

        let orgWinnr = winnr()

        " 跳转至预览窗口
        try
            noautocmd wincmd P
        catch /.*/
            return
        endtry
        if &previewwindow           " 如果确实转到了预览窗口……

"           if !buflisted(orgbuf)   " 如果需要打开的预览缓冲没有在可用缓冲列表
"               setlocal buftype=nowrite
"               setlocal bufhidden=delete
"               setlocal noswapfile
"               setlocal nobuflisted
"               setlocal noma
"           endif

            if has("folding")
                silent! .foldopen   " 展开折叠的行
            endif

"           call search("$", "b")   " 到前一行的行尾
            let w = substitute(w, '\\', '\\\\', "")
"           call search('\<\V' . w . '\>')      " 定位光标在匹配的单词上
            call search('\<\V' . w . '\>', "c") " 定位光标在匹配的单词上
            " 给在此位置的单词加上匹配高亮
            "hi PreviewWord guifg=cyan guibg=grey40 term=bold ctermbg=green
            hi link PreviewWord Search
            exec 'match PreviewWord "\%' . line(".") . 'l\%' . col(".") . 'c\k*"'
            normal! zz

            if flag == 0
                " 返回原来的窗口
                exec 'noautocmd' orgWinnr 'wincmd w'
            endif
        endif
    endif
endfunction
"}}}2

let s:last_repeat = 0
" 普通模式 <CR>
func myrc#MyEnter()
    if &buftype ==# 'quickfix'
        " 智能寻找一个可用的窗口
        let winid = myrc#GetWindowIdForQuickfixToOpen()
        if winid != 0
            " 通过改变上一个窗口来控制 quickfix 打开的窗口
            let bak_ei = &ei
            set eventignore=all
            call win_gotoid(winid)
            let &ei = bak_ei
            noautocmd wincmd p
        endif
        exec "normal! \<CR>"
        return
    elseif !empty(getcmdwintype())
        exec "normal! \<CR>"
        return
    elseif &ft == 'floggraph'
        exec "normal \<CR>"
        return
    endif
    if empty(@:)
        return
    endif
    let now = localtime()
    let diff = now - s:last_repeat
    " 10 秒内重复的话，不提示
    if diff >= 10
        let answer = input('repeat command: ' . @: . ', confirm? (y/n)', 'y')
        if answer !~? '^y'
            return
        endif
    endif
    let s:last_repeat = now
    normal! @:
endfunc

func s:realpath(path)
    return resolve(fnamemodify(a:path, ':p'))
endfunc

func myrc#shellsplit(cmdline)
    return split(a:cmdline, '\\\@<!\s\+')
endfunc

func myrc#FileComplete(ArgLead, CmdLine, CursorPos)
    let head = substitute(a:CmdLine, '^\s*Rg\s\+', '', 'g')
    let args = myrc#shellsplit(head)
    if empty(args)
        let head = ''
    elseif head[-2:-1] ==# '\ '
        " abc\ |
        let head = args[-1]
    elseif head[-1:-1] ==# ' '
        " abc\  |
        let head = ''
    else
        let head = args[-1]
    endif
    " 暂时只处理部分转义字符，对于自己来说，足够使用了
    let head = substitute(head, '\\\([\\ \t%|]\)', '\1', 'g')
    if head !~# '/$'
        if isdirectory(head)
            return [fnameescape(head) . '/']
        endif
    endif
    let result = glob(head . '*', 0, 1)
    return map(result, {idx, val -> isdirectory(val) ? fnameescape(val).'/' : fnameescape(val)})
endfunc

func myrc#i_CTRL_E()
    if get(g:, 'did_coc_loaded') && coc#pum#visible()
        return coc#pum#cancel()
    endif
    if pumvisible()
        return "\<C-e>"
    else
        return "\<End>"
    endif
endfunc

let s:popup_winid = 0
let s:popup_orig_pos = []
let s:default_border = [
    \   [ '', 'NormalFloat' ],
    \   [ '', 'NormalFloat' ],
    \   [ '', 'NormalFloat' ],
    \   [ ' ', 'NormalFloat' ],
    \   [ '', 'NormalFloat' ],
    \   [ '', 'NormalFloat' ],
    \   [ '', 'NormalFloat' ],
    \   [ ' ', 'NormalFloat' ],
    \ ]

" autoclose=1
func myrc#popup(lines, width, height, ...)
    if !has('nvim')
        return mydict#popup(a:lines)
    endif
    if !exists('*nvim_open_win')
        return -1
    endif
    if s:popup_winid
        return
    endif

    " 使用 nvim 的 floating window
    let bak_ei = &eventignore
    let &eventignore = 'all'    " BUG: nvim 仍然会触发 CursorMoved 事件
    let orig_winid = win_getid()

    let options = {
            \ 'relative': 'cursor',
            \ 'row': 1,
            \ 'col': -1,
            \ 'width': a:width,
            \ 'height': a:height,
            \ 'border': s:default_border,
            \ 'zindex': 199,
            \ }
    let enter = 1
    " @ 创建一个 popup 窗口
    " TODO: 窗口的尺寸受限于 &lines, &columns 以及当前的位置（无法完美实现）
    let winid = nvim_open_win(0, enter, options)

    " @ 设置窗口信息，添加内容
    enew
    call setwinvar(winid, '&wrap', 0)
    call setwinvar(winid, '&winhighlight', 'Normal:NormalFloat,CursorLine:PmenuSel')
    " 以下两场产生一个临时窗口，关闭即清空
    setlocal bufhidden=wipe colorcolumn= nobuflisted nocursorcolumn nocursorline
    setlocal nolist nonumber norelativenumber nospell noswapfile matchpairs=
    call append(1, a:lines)
    " 删除多余的首行
    1delete
    " 锁定窗口不能修改
    setlocal nomodifiable nomodified

    autocmd BufUnload <buffer> call myrc#popup_close()

    " 跳回原始窗口
    call win_gotoid(orig_winid)

    let autoclose = get(a:000, 0, 1)
    if autoclose
        " nvim 有 CursorMoved 的 BUG，暂时用一定的方法规避掉这个 BUG
        let pos = getpos('.')
        let s:popup_orig_pos = [orig_winid, pos[1], pos[2]]
        augroup myrc_popup
            autocmd CursorMoved * call myrc#popup_auto_close()
            autocmd InsertEnter * call myrc#popup_auto_close(1)
            autocmd InsertLeave * call myrc#popup_auto_close(1)
            autocmd WinLeave * call myrc#popup_auto_close(1)
        augroup END
    endif

    let &eventignore = bak_ei
    let s:popup_winid = winid
    return winid
endfunc

func myrc#popup_close()
    if !s:popup_winid
        return
    endif
    let bak_ei = &eventignore
    let &eventignore = 'all'

    let orig_winid = win_getid()
    call win_gotoid(s:popup_winid)
    wincmd c
    call win_gotoid(orig_winid)

    let s:popup_winid = 0
    let &eventignore = bak_ei
endfunc

" force=0
func myrc#popup_auto_close(...)
    let force = get(a:000, 0, 0)
    " 规避 nvim 的 BUG
    if !force && !empty(s:popup_orig_pos)
        let pos = getpos('.')
        if win_getid() == s:popup_orig_pos[0] && pos[1] == s:popup_orig_pos[1]
                \ && pos[2] == s:popup_orig_pos[2]
            return
        endif
    endif
    " 删除自动组
    augroup myrc_popup
        autocmd!
    augroup END
    call filter(s:popup_orig_pos, 0)
    call myrc#popup_close()
endfunc

let s:init_man = 0
func myrc#Man(cmd, mods, args)
    if s:init_man
        return
    endif
    exec 'delcommand' a:cmd
    runtime ftplugin/man.vim
    let s:init_man = 1
    exec a:mods a:cmd a:args
endfunc

function! myrc#MacroComment() "{{{
    let l:firstline = line("'<")
    let l:lastline = line("'>")
    let l:curline = line(".")
    exec l:firstline . "put! ='#if 0'"
    exec l:lastline + 1 . "put ='#endif'"
    exec l:curline + 1
endfunction
"}}}

function! myrc#ToggleCase() "{{{
    let sLine = getline('.')
    let nEndIdx = col('.') - 2
    let sWord = matchstr(sLine[: nEndIdx], '\zs\k*\ze$')
    if sWord ==# ''
        return ''
    endif

    if sWord =~# '[a-z]'
        call setline(line('.'), substitute(sLine[: nEndIdx], '\zs\k*\ze$',
                    \   toupper(sWord), '') . sLine[nEndIdx+1 :])
    else
        call setline(line('.'), substitute(sLine[: nEndIdx], '\zs\k*\ze$',
                    \   tolower(sWord), '') . sLine[nEndIdx+1 :])
    endif

    return ''
endfunction
"}}}

function! myrc#i_InsertHGuard() "{{{
    let gudname = "__".substitute(toupper(expand("%:t")), "\\.", "_", "g")."__"
    return "#ifndef ".gudname."\<CR>"."#define ".gudname."\<CR>\<CR>\<CR>\<CR>\<CR>\<CR>"."#endif /* ".gudname." */\<Up>\<Up>\<Up>"
endfunction
"}}}

function! myrc#n_BufferDelete()
    let curb = bufnr('%')
    if bufnr('#') != -1
        buffer #
    else
        bNext
    endif
    exec "bw " . curb
endfunction

let s:bak_ei = &ei
function! myrc#restore_ei(...) abort
    let &ei = s:bak_ei
    return ''
endfunction

" 插入模式 <CR>
function! myrc#SmartEnter() abort
    if pumvisible()
        let s:bak_ei = &ei
        set ei=all
        call feedkeys("\<C-y>", 'n')
        if has('nvim')
            lua vim.schedule(vim.fn['myrc#restore_ei'])
        else
            call timer_start(0, "myrc#restore_ei")
        endif
    elseif exists(':CmpStatus') == 2 && luaeval("require('cmp').visible()")
        "lua require('cmp').confirm({select = false, behavior = require('cmp').ConfirmBehavior.Insert})
        lua require('plugins.config.nvim-cmp').confirm({select = false, behavior = require('cmp').ConfirmBehavior.Insert})()
    elseif exists('g:did_coc_loaded') && coc#pum#visible()
        call coc#pum#select_confirm()
    else
        call feedkeys("\<CR>", 'n')
    endif
    return ''
endfunction

function! myrc#yankcmd()
    if !has_key(s:, 'yankcmd')
        let s:yankcmd = ''
        if s:IsWindowsOS()
            if executable('win32yank.exe')
                let s:yankcmd = 'win32yank.exe -i'
            endif
        elseif s:IsMacOS()
            if executable('pbcopy')
                let s:yankcmd = 'pbcopy'
            endif
        endif
    endif
    return s:yankcmd
endfunction

function! myrc#pastecmd()
    if !has_key(s:, 'pastecmd')
        let s:pastecmd = ''
        if s:IsWindowsOS()
            if executable('win32yank.exe')
                let s:pastecmd = 'win32yank.exe -o'
            endif
        elseif s:IsMacOS()
            if executable('pbpaste')
                let s:pastecmd = 'pbpaste'
            endif
        endif
    endif
    return s:pastecmd
endfunction

function! myrc#enable_oscyank() abort
    let s:enable_oscyank = v:true
endfunction

function! myrc#disable_oscyank() abort
    let s:enable_oscyank = v:false
endfunction

function! myrc#OSCYank(str) abort
    call plug#load('vim-oscyank')
    if exists('*OSCYank')
        call OSCYank(a:str)
    endif
endfunction

" clipboard yank
function! myrc#cby() abort
    if (exists('$SSH_CONNECTION') || s:enable_oscyank) && exists(':OSCYankVisual')
        OSCYankVisual
        return
    endif
    let cmd = myrc#yankcmd()
    if empty(cmd)
        return
    endif
    call system(cmd, getreg('"'))
endfunction

" clipboard paste
function! myrc#cbp() abort
    if (exists('$SSH_CONNECTION') || s:enable_oscyank) && exists(':OSCYankVisual')
        return ''
    endif
    let cmd = myrc#pastecmd()
    if empty(cmd)
        return ''
    endif
    call setreg('"', system(cmd))
    return ''
endfunction

function! myrc#prepIpaste() abort
    let s:bak_paste = &paste
    set paste
    return ''
endfunction

function! myrc#postIpaste() abort
    let &paste = s:bak_paste
    return ''
endfunction

function! myrc#_paste()
    call feedkeys("\<C-r>\"", 'n')
    return ''
endfunction

function! myrc#optionset_hook()
    let option = expand('<amatch>')
    if option ==# 'lines'
        let diff = v:option_new - v:option_old
        let op = 'add'
        if diff < 0
            let op = 'sub'
        endif
        let ppp = get(g:, 'line_ppp', 10)
        let cmd = printf("open -g 'hammerspoon://resizeWindow?op=%s&height=%d'",
                \        op, abs(diff) * ppp)
        call system(cmd)
    endif
    if option ==# 'columns'
        let diff = v:option_new - v:option_old
        let op = 'add'
        if diff < 0
            let op = 'sub'
        endif
        let ppp = get(g:, 'column_ppp', 10)
        let cmd = printf("open -g 'hammerspoon://resizeWindow?op=%s&width=%d'",
                \        op, abs(diff) * ppp)
        call system(cmd)
    endif
endfunction

function! myrc#drop(arglist)
    let name = (type(a:arglist) == v:t_string)? a:arglist : a:arglist[0]
    let cmd = get(g:, 'terminal_edit', 'tab drop')
    silent exec cmd . ' ' . fnameescape(name)
    return ''
endfunction

function! myrc#close() abort
    let winnr = winnr('#')
    let winid = win_getid(winnr)
    try
        close
    catch /^Vim\%((\a\+)\)\=:E5601:/
        " Vim(close):E5601: Cannot close window, only floating window would remain
        " BUG: https://github.com/neovim/neovim/issues/11440
        q!
    endtry
    " nvim 的 prev window 逻辑和 vim 的不一样, 会有奇怪的情况
    if !has('nvim')
        call win_gotoid(winid)
    endif
endfunction

" 打开指定缓冲区的窗口数目
function! s:BufInWinCount(nBufNr) "{{{2
    let nCount = 0
    let nWinNr = 1
    while 1
        let nWinBufNr = winbufnr(nWinNr)
        if nWinBufNr < 0
            break
        endif
        if nWinBufNr ==# a:nBufNr
            let nCount += 1
        endif
        let nWinNr += 1
    endwhile

    return nCount
endfunction

" 判断窗口是否可用
" 可用 - 即可用其他 buffer 替换本窗口而不会令本窗口原来的 buffer 的内容消失
function! s:IsWindowUsable(nWinNr) "{{{2
    let nWinNr = a:nWinNr
    if empty(nWinNr)
        return 0
    endif
    " 特殊窗口，如特殊缓冲类型的窗口、预览窗口
    let bIsSpecialWindow = getwinvar(nWinNr, '&buftype') !=# ''
                \|| getwinvar(nWinNr, '&previewwindow')
    if bIsSpecialWindow
        return 0
    endif

    " 窗口缓冲是否已修改
    let bModified = getwinvar(nWinNr, '&modified')

    " 如果可允许隐藏，则无论缓冲是否修改
    if &hidden
        return 1
    endif

    " 如果缓冲区没有修改，或者，已修改，但是同时有其他窗口打开着，则表示可用
    if !bModified || s:BufInWinCount(winbufnr(nWinNr)) >= 2
        return 1
    else
        return 0
    endif
endfunction

" 获取第一个"可用"(常规, 非特殊)的窗口
" 特殊: 特殊的缓冲区类型、预览缓冲区、已修改的缓冲并且不能隐藏
" Return: 窗口编号 - -1 表示没有可用的窗口
function! s:GetFirstUsableWinNr() "{{{2
    let i = 1
    while i <= winnr("$")
        if s:IsWindowUsable(i)
            return i
        endif

        let i += 1
    endwhile
    return -1
endfunction

function! myrc#GetWindowIdForNvimTreeToOpen() abort
    let prev_winnr = winnr('#')
    if s:IsWindowUsable(prev_winnr)
        return win_getid(prev_winnr)
    endif
    let prev_prev_winid = getwinvar(prev_winnr, 'prev_winid')
    if s:IsWindowUsable(prev_prev_winid)
        return prev_prev_winid
    endif
    let nr = s:GetFirstUsableWinNr()
    if nr != -1
        return win_getid(nr)
    endif
    " 当前仅剩下 nvim-tree 窗口了或没有可用的窗口了
    let width = luaeval("require('nvim-tree').config.view.width")
    if &columns > width + 1
        exec 'rightbelow' (&columns - (width + 1)) 'vnew'
        return win_getid()
    endif
    " 返回 0 的话, nvim-tree 会按照自己逻辑新建一个可用窗口
    return 0
endfunction

function! myrc#GetWindowIdForQuickfixToOpen() abort
    let prev_winnr = winnr('#')
    if s:IsWindowUsable(prev_winnr)
        return win_getid(prev_winnr)
    endif
    let prev_prev_winid = getwinvar(prev_winnr, 'prev_winid')
    if s:IsWindowUsable(prev_prev_winid)
        return prev_prev_winid
    endif
    let nr = s:GetFirstUsableWinNr()
    if nr != -1
        return win_getid(nr)
    endif
    " 当前仅剩下当前窗口或没有可用的窗口了
    return 0
endfunction

function! myrc#LogSetup() abort
    setl termguicolors
    setl nowrap cursorline
    setl cc=
    silent! setf log
endfunction

function! myrc#MyTabLine() abort
    let s = ''
    let nr = tabpagenr()
    for i in range(tabpagenr('$'))
        let active = (i + 1 == nr)
        " 选择高亮
        if active
          let s ..= '%#MyTabLineSel#'
        else
          let s ..= '%#MyTabLineNotSel#'
        endif

        " 设置标签页号 (用于鼠标点击)
        let s ..= ' %' .. (i + 1) .. 'T'

        " MyTabLabel() 提供标签
        let s ..= printf('%%{myrc#MyTabLabel(%d, %d)} ', i + 1, active)
    endfor

    " 最后一个标签页之后用 TabLineFill 填充并复位标签页号
    let s ..= '%#MyTabLineFill#%T'

    " 右对齐用于关闭当前标签页的标签
    if tabpagenr('$') > 1
        let s ..= '%=%#MyTabLineClose#%999X X '
    endif

    return s
endfunction

function! s:tab_filename(n) abort
    let buflist = tabpagebuflist(a:n)
    let winnr = tabpagewinnr(a:n)
    let _ = expand('#'.buflist[winnr - 1].':t')
    return _ !=# '' ? _ : '[No Name]'
endfunction

function! s:tab_modified(n) abort
    let winnr = tabpagewinnr(a:n)
    return gettabwinvar(a:n, winnr, '&modified') ? '+' : (gettabwinvar(a:n, winnr, '&modifiable') ? '' : '-')
endfunction

function myrc#MyTabLabel(n, active)
    " 支持使用 t:title 指定标签名称
    let title = gettabvar(a:n, 'title', 0)
    if type(title) == v:t_string
        return title
    endif
    let _ = []
    call add(_, a:n)
    call add(_, s:tab_filename(a:n))
    call add(_, s:tab_modified(a:n))
    return join(filter(_, 'v:val !=# ""'), ' ')
endfunction

function myrc#Cstag() abort
    if &filetype == "help" || &filetype == 'man'
        exec "normal! \<C-]>"
        return
    endif
    let cword = expand('<cword>')
    " 优先使用 tag 跳转然后再用 cstag
    try
        if &tagfunc ==# 'v:lua.vim.lsp.tagfunc'
            " 只能这样做, 舍弃了 Cstag 的 fallback 功能
            " 如果使用 noice.nvim 的话, 只能用原始的 <C-]> 功能
            if luaeval('package.loaded.noice ~= nil')
                call feedkeys("\<C-]>", 'n')
            else
                call feedkeys("g\<C-]>", 'n')
            endif
        else
            exec 'tjump' cword
        endif
    catch
        exec "Cstag" cword
    endtry
endfunction

" 插入模式 <Tab>
" 有补全引擎工作的时候, 就补全或者展开snippet(片段), 否则 触发 <c-x>xxx 系列补全
function! myrc#SuperTab()
    " BUG: vim 脚本的绑定无法获取到正确的值, 用 vim.api.nvim_set_keymap 的方式才能正常
    "echomsg luaeval("require('cmp').visible()")
    let preChar = getline('.')[col('.') - 2]
    if exists('g:did_coc_loaded') && coc#pum#visible()
        call coc#pum#_navigate(1, 1)
    elseif pumvisible()
        call feedkeys("\<C-n>", 'n')
    elseif preChar == '' || preChar =~ '\s'
        call feedkeys("\<Tab>", 'n')
    elseif (getline('.')[col('.') - 3] == '-' && preChar == '>') || preChar == '.'
        call feedkeys("\<C-x>\<C-o>", 'n')
    else
        " BUG: 必须用 lua vim.api.nvim_set_keymap 的方式才能正常工作
        if exists(':CmpStatus') == 2 && luaeval("require('cmp').visible()")
            call feedkeys("\<Down>")
        elseif exists('*luasnip#expand_or_jumpable') && luasnip#expand_or_jumpable()
            call feedkeys("\<Plug>luasnip-expand-or-jump")
        elseif exists('*neosnippet#expandable_or_jumpable') && neosnippet#expandable_or_jumpable()
            call feedkeys("\<Plug>(neosnippet_expand_or_jump)")
        elseif exists('g:did_coc_loaded') && coc#expandableOrJumpable()
            call coc#rpc#request('doKeymap', ['snippets-expand-jump',''])
        else
            if &ft ==# 'c' || &ft ==# 'cpp'
                call feedkeys("\<C-n>", 'n')
            else
                call feedkeys("\<C-x>\<C-n>", 'n')
            endif
        endif
    endif
    return ''
endfunction

" 插入模式 <S-Tab>
function myrc#ShiftTab()
    if pumvisible()
        call feedkeys("\<C-p>", 'n')
    elseif exists(':CmpStatus') == 2 && luaeval("require('cmp').visible()")
        call feedkeys("\<Up>")
    elseif exists('*luasnip#expand_or_jumpable') && luasnip#expand_or_jumpable()
        lua require('luasnip').jump(-1)
    else
        call feedkeys("\<Tab>", 'n')
    endif
    return ''
endfunction

" 上下文弹出菜单(鼠标右键菜单), 快捷键一般为 <C-p>
function myrc#ContextPopup(...)
    let cmd = get(a:000, 0) ? 'popup!' : 'popup'
    exec cmd 'PopUp'
endfunction

let s:status_refresh_timer = -1
function s:RefreshStatusTables(fname, bufid, ...) abort
    if bufwinid(a:bufid) < 0
        "call myrc#StopRefreshStatusTables()
        return
    endif
    call v:lua.require'mylib.texttable'.buffer_render_status(a:bufid, expand(a:fname))
endfunction
function myrc#StopRefreshStatusTables()
    call timer_stop(s:status_refresh_timer)
    let s:status_refresh_timer = -1
endfunc
" (fname, interval=1000, bufid=bufnr())
function myrc#RefreshStatusTables(fname, ...) abort
    if s:status_refresh_timer != -1
        echohl WarningMsg
        echo "timer is already running"
        echohl NONE
        return
    endif
    let interval = get(a:000, 0, 1000)
    let bufid = str2nr(get(a:000, 1, bufnr()))
    call nvim_set_option_value('buftype', 'nofile', {'buf': bufid})
    call nvim_set_option_value('swapfile', v:false, {'buf': bufid})
    call nvim_set_option_value('bufhidden', 'wipe', {'buf': bufid})
    call nvim_set_option_value('undolevels', 100, {'buf': bufid})
    call nvim_set_option_value('wrap', v:false, {'win': bufwinid(bufid)})
    call nvim_set_option_value('buflisted', v:false, {'buf': bufid})
    call nvim_set_option_value('colorcolumn', '', {'win': bufwinid(bufid)})
    call nvim_set_option_value('list', v:false, {'win': bufwinid(bufid)})
    call nvim_set_option_value('cursorline', v:true, {'win': bufwinid(bufid)})
    call nvim_set_option_value('filetype', 'status_table', {'buf': bufid})
    exec printf("lua vim.keymap.set('n', '<CR>', function() require('mylib.texttable').toggle_sort_on_header('%s') end, { buffer = %d })", a:fname, bufid)
    exec printf("lua vim.keymap.set('n', '<2-LeftMouse>', '<CR>', { buffer = %d, remap = true })", bufid)
    call s:RefreshStatusTables(a:fname, bufid)
    let s:status_refresh_timer = timer_start(interval,
        \ function('s:RefreshStatusTables', [a:fname, bufid]), {'repeat': -1})
    exec printf('autocmd BufUnload <buffer=%d> call myrc#StopRefreshStatusTables()', bufid)
endfunction

function! myrc#MouseMark() "{{{2
    if &ft == "help"
        execute "normal! \<C-]>"
        return
    endif
    let c = getline('.')[col('.')-1]
    if &buftype ==# 'quickfix' || &ft == 'floggraph'
        call myrc#MyEnter()
        return
    elseif c == '(' || c == ')' || c == '[' || c == ']' || c == '{' || c == '}'
        execute "normal! \<2-LeftMouse>"
        return
    endif
    call feedkeys("\<Plug>MarkSet")
endfunction
"}}}2

" Show hover when provider exists, fallback to vim's builtin behavior.
function! myrc#ShowDocumentation()
    if has('nvim-0.10') && luaeval('#vim.lsp.get_clients({bufnr=vim.fn.bufnr()})') > 0
        lua vim.lsp.buf.hover()
    elseif exists('g:did_coc_loaded') && CocAction('hasProvider', 'hover')
        call CocActionAsync('definitionHover')
    else
        call feedkeys('K', 'in')
    endif
endfunction

function! myrc#FixDosFmt() "{{{2
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

" vim: fdm=indent fen fdl=0 sw=4 sts=-1 et
