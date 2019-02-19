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
    let options['exit_cb'] = function('s:exit_cb', [], dict)
    let options['err_io'] = 'out'
    let options['out_cb'] = function('s:output_cb')
    let s:gtags_job = job_start([prg], options)
endfunction

function myrc#UpdateGtags(fname)
    if !cscope_connection(1, 'GTAGS')
        return
    endif
    let fname = s:realpath(a:fname)
    if !has_key(s:gtags_files_dict, fname)
        return
    endif
    " "cd %s && %s -f %s --single-update %s"
    let prg = exepath(substitute(&cscopeprg, '-cscope\>', '', ''))
    let cmd = [prg, '--single-update', fname]
    let s:gtags_job = job_start(cmd)
endfunction

" cscope 的场合，直接添加就不管了
" gtags 的场合，以 gtags.files 为基准，作增量更新
" gtags 的增量更新包括：添加文件，更新文件，删除文件
" 本函数只支持 gtags 的“更新文件”情况下的增量更新
function! myrc#CscopeAdd(name, ...) " ... -> refresh_gtags_files
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
        "redraw
    elseif a:name =~? 'cscope'
        if !executable('cscope')
            return
        endif
        if &cscopeprg =~# '\<gtags\>'
            silent cscope kill -1
            set cscopeprg=cscope
        endif
        "redraw
    else
        return
    endif
    let save_csverb = &cscopeverbose
    set cscopeverbose
    exec printf('silent! cscope kill %s %s', fnameescape(a:name), fnameescape(prepath))
    exec printf('cscope add %s %s', fnameescape(a:name), fnameescape(prepath))
    let &cscopeverbose = save_csverb
    if &cscopeprg =~# '\<gtags-cscope\>'
        let refresh_gtags_files = get(a:000, 0, 1)
        if refresh_gtags_files
            " FIXME: 不能处理编码
            let gtags_files = readfile(s:joinpath(prepath, 'gtags.files'))
            call filter(s:gtags_files_dict, 0)
            for file in gtags_files
                let s:gtags_files_dict[s:realpath(file)] = 1
            endfor
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

function! myrc#AsyncRun(qargs)
    if !exists('*asyncrun#run')
        try
            exec 'AsyncRun'
        catch
        endtry
    endif
    call asyncrun#run(0, '', 'rg --vimgrep ' . a:qargs)
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

" vim: fdm=indent fen fdl=0 et sts=4
