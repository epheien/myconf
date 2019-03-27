" 用于 vimrc 的懒加载函数

if exists('s:loaded')
    finish
endif
let s:loaded = 1
let s:gtags_files_dict = {}

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
    exec printf('silent! cscope kill %s %s', fnameescape(a:name), fnameescape(prepath))
    if a:name =~# '\<GTAGS$'
        " NOTE: 添加 GTAGS 的时候，只能添加当前目录下的 GTAGS
        exec 'silent' 'cd' fnameescape(prepath)
        exec printf('cscope add %s %s', 'GTAGS', fnameescape(prepath))
        silent cd -
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
func myrc#RepeatCommand()
    if empty(@:)
        return
    endif
    if &buftype =~# '\<quickfix\>'
        exec "normal! \<CR>"
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

" 用于处理 deoplete 弹出补全菜单时，<C-e> 会重复弹菜单的问题
" 因为 <C-e> 的时候，会触发 CompleteDone CursorMovedI TextChangedI 时间
" TODO: 只能处理几种 case，要完全解决的话，只能报 bug 给 deoplete
func myrc#i_CTRL_E()
    if pumvisible()
        if exists('*deoplete#close_popup')
            call deoplete#close_popup()
        endif
        return "\<C-e>"
    else
        return "\<End>"
    endif
endfunc

let s:popup_winid = 0
let s:popup_orig_pos = []
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
            \ 'col': 0,
            \ 'width': a:width,
            \ 'height': a:height,
            \ }
    let enter = 1
    " @ 创建一个 popup 窗口
    " TODO: 窗口的尺寸受限于 &lines, &columns 以及当前的位置（无法完美实现）
    let winid = nvim_open_win(0, enter, options)

    " @ 设置窗口信息，添加内容
    enew
    call setwinvar(winid, '&wrap', 0)
    call setwinvar(winid, '&winhighlight', 'Normal:Pmenu,CursorLine:PmenuSel')
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

function! myrc#complete_done() abort
    let s:bak_ei = &ei
    set ei=all
    call feedkeys("\<C-y>")
    call timer_start(0, "myrc#restore_ei")
    return ''
endfunction

" vim: fdm=indent fen fdl=0 et sts=4
