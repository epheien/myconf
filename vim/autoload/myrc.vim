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
        let s:gtags_files_dict[resolve(file)] = 1
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
    let fname = resolve(a:fname)
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
                let s:gtags_files_dict[resolve(file)] = 1
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

" vim: fdm=indent fen fdl=0 et sts=4
