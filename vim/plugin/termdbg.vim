"
" NOTE:
"   - 只留一个窗口显示 WinBar，如果此窗口被关闭，则新建一个窗口再添加 WinBar

" In case this gets loaded twice.
if exists('s:loaded')
  finish
endif
let s:loaded = 1

let s:pc_id = 1002
let s:break_id = 1003
let s:winbar_winids = []
let s:cache_lines = []
let g:cache_lines = s:cache_lines
let s:dbg_type = ''
let s:prompt = '(Pdb) '

if &background == 'light'
  hi default TermdbgCursor term=reverse ctermbg=lightblue guibg=lightblue
else
  hi default TermdbgCursor term=reverse ctermbg=darkblue guibg=darkblue
endif
hi default debugBreakpoint term=reverse ctermbg=red guibg=red

function! s:InitVariable(var, value, ...)
  let force = a:0 > 0 ? a:1 : 0
  if force || !exists(a:var)
    if exists(a:var)
      unlet {a:var}
    endif
    let {a:var} = a:value
  endif
endfunction

call s:InitVariable('g:termdbg_pdb_prog',   'pdb')
call s:InitVariable('g:termdbg_pdb3_prog',  'pdb3')
call s:InitVariable('g:termdbg_ipdb_prog',  'ipdb')
call s:InitVariable('g:termdbg_ipdb3_prog', 'ipdb3')

command -nargs=+ -complete=file -bang Termdbg call s:StartDebug(<bang>0, '', <f-args>)

command -nargs=+ -complete=file -bang TermdbgPdb
      \ call s:StartDebug(<bang>0, 'pdb', g:termdbg_pdb_prog, <f-args>)
command -nargs=+ -complete=file -bang TermdbgPdb3
      \ call s:StartDebug(<bang>0, 'pdb3', g:termdbg_pdb3_prog, <f-args>)
"command -nargs=+ -complete=file -bang TermdbgIPdb
      "\ call s:StartDebug(<bang>0, 'ipdb', g:termdbg_ipdb_prog, <f-args>)
"command -nargs=+ -complete=file -bang TermdbgIPdb3
      "\ call s:StartDebug(<bang>0, 'ipdb3', g:termdbg_ipdb3_prog, <f-args>)

function s:StartDebug(bang, type, ...)
  if exists('s:dbgwin')
    echoerr 'Terminal debugger is already running'
    return
  endif
  let s:startwin = win_getid(winnr())
  let s:startsigncolumn = &signcolumn

  let s:ptybuf = term_start(a:000, {
        \ 'term_name': 'Terminal debugger',
        \ 'out_cb': function('s:out_cb'),
        \ 'err_cb': function('s:err_cb'),
        \ 'exit_cb': function('s:exit_cb'),
        \ 'term_finish': 'close',
        \ })
  let s:dbgwin = win_getid(winnr())

  call s:InstallCommands()
  call win_gotoid(s:startwin)
  call s:InstallWinbar()

  " Sign used to highlight the line where the program has stopped.
  " There can be only one.
  sign define TermdbgCursor linehl=TermdbgCursor

  " Sign used to indicate a breakpoint.
  " Can be used multiple times.
  sign define debugBreakpoint text=>> texthl=debugBreakpoint

  if a:type ==# 'ipdb' || a:type ==# 'ipdb3'
    let s:dbg_type = 'ipdb'
    let s:prompt = 'ipdb> '
  elseif a:type ==# 'pdb' || a:type ==# 'pdb3'
    let s:dbg_type = 'pdb'
    let s:prompt = '(Pdb) '
  endif
endfunction

function s:out_cb(chan, msg)
  "echomsg string(a:msg)

  let lines = split(a:msg, "\r")
  call extend(s:cache_lines, lines)
  if len(s:cache_lines) > 100
    let s:cache_lines = s:cache_lines[-100:-1]
  endif

  if a:msg =~# '(Pdb) $'
    let pdb_cnt = 0
    for idx in range(len(s:cache_lines)-1, 0, -1)
      let line = s:cache_lines[idx]
      " remove prefixed NL
      if line[0] == "\n"
        let line = line[1:]
      endif
      if line ==# s:prompt
        let pdb_cnt += 1
        if pdb_cnt >= 2
          break
        endif
      endif
      if line !~# '^> '
        continue
      endif
      if !s:_LocateCursor(line)
        execute 'sign unplace' s:pc_id
      endif
      break
    endfor
  endif
endfunction

function s:err_cb(chan, msg)
endfunction

function s:exit_cb(job, status)
  execute 'bwipe!' s:ptybuf
  unlet s:dbgwin
  call filter(s:cache_lines, 0)

  let curwinid = win_getid(winnr())

  if win_gotoid(s:startwin)
    let &signcolumn = s:startsigncolumn
  endif

  call s:DeleteCommands()
  call s:DeleteWinbar()
  execute 'sign unplace' s:pc_id

  sign undefine TermdbgCursor
  sign undefine debugBreakpoint
endfunction

function s:getbufmaxline(bufnr)
  return pyxeval('len(vim.buffers['.(a:bufnr).'])')
endfunction

func s:GotoStartwinOrCreateIt()
  if !win_gotoid(s:startwin)
    new
    let s:startwin = win_getid(winnr())
    call s:InstallWinbar()
  endif
endfunc

" Install the window toolbar in the current window.
func s:InstallWinbar()
  if has('menu') && &mouse != ''
    nnoremenu WinBar.Next   :TNext<CR>
    nnoremenu WinBar.Step   :TStep<CR>
    nnoremenu WinBar.Finish :TFinish<CR>
    nnoremenu WinBar.Cont   :TContinue<CR>
    call add(s:winbar_winids, win_getid(winnr()))
  endif
endfunc

function s:TermdbgNext()
  call s:SendCommand('next')
endfunction

function s:TermdbgStep()
  call s:SendCommand('step')
endfunction

function s:TermdbgFinish()
  call s:SendCommand('return')
endfunction

function s:TermdbgContinue()
  call s:SendCommand('continue')
endfunction

" 返回 0 表示定位失败，否则表示定位成功
func s:_LocateCursor(msg)
  if a:msg[0:1] !=# '> '
    return 0
  endif

  let wid = win_getid(winnr())

  let matches = matchlist(a:msg, '\v^\> (.+)\((\d+)\).*\(.*\).*$')
  let fname = ''
  if len(matches) >= 3
    let fname = matches[1]
    if filereadable(fname)
      let lnum = str2nr(matches[2])
    endif
  endif
  if empty(fname) || fname[0] !=# '/'
    return 0
  endif

  call s:GotoStartwinOrCreateIt()

  " 如果调试窗口的编辑的文件不是正在调试的文件，则切换为正在调试的文件
  if expand('%:p') != fnamemodify(fname, ':p')
    " 如果此窗口的文件已经修改，就分隔一个窗口来显示调试文件
    if &modified
      " TODO: find existing window
      execute 'split' fnameescape(fname)
      let s:startwin = win_getid(winnr())
      call s:InstallWinbar()
    else
      execute 'edit' fnameescape(fname)
    endif
  endif

  " 定位调试行
  execute lnum
  execute 'sign unplace' s:pc_id
  execute 'sign place ' . s:pc_id . ' line=' . lnum . ' name=TermdbgCursor file=' . fname
  setlocal signcolumn=yes

  call win_gotoid(wid)

  return 1
endfunc

function g:LocateCursor()
  if !exists('s:ptybuf')
    return
  endif
  let maxlnum = s:getbufmaxline(s:ptybuf)
  let min = 1
  let pdb_cnt = 0
  for lnum in range(maxlnum, min, -1)
    let line = getbufline(s:ptybuf, lnum)[0]
    if line ==# s:prompt
      let pdb_cnt += 1
      "if pdb_cnt >= 2
        "break
      "endif
    endif
    if line !~# '^> '
      continue
    endif
    if !s:_LocateCursor(line)
      execute 'sign unplace' s:pc_id
    endif
    break
  endfor
endfunction

func s:InstallCommands()
  command TNext call s:TermdbgNext()
  command TStep call s:TermdbgStep()
  command TFinish call s:TermdbgFinish()
  command TContinue call s:TermdbgContinue()
  command TLocateCursor call g:LocateCursor()
endfunc

func s:DeleteCommands()
  delcommand TNext
  delcommand TStep
  delcommand TFinish
  delcommand TContinue
  delcommand TLocateCursor
endfunc

func s:DeleteWinbar()
  let curwinid = win_getid(winnr())
  for winid in s:winbar_winids
    if win_gotoid(winid)
      aunmenu WinBar.Next
      aunmenu WinBar.Step
      aunmenu WinBar.Finish
      aunmenu WinBar.Cont
    endif
  endfor
  call win_gotoid(curwinid)
  let s:winbar_winids = []
endfunc

func s:SendCommand(cmd)
  call term_sendkeys(s:ptybuf, a:cmd . "\r")
endfunc

" vi:set sts=2 sw=2 et:
