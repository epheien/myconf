" 实现代码取自 vim-go 并精简

" NOTE: 无法分辨是否嵌套, 只会无脑往前搜索指定的 go 语法模式
function! mygo#BlockJumpPrev() abort
  call search('^[a-zA-Z_]\+.\+{$', 'bWs')
endfunction

" Get all lines in the buffer as a a list.
function! s:GetLines()
  let buf = getline(1, '$')
  if &encoding != 'utf-8'
    let buf = map(buf, 'iconv(v:val, &encoding, "utf-8")')
  endif
  if &l:fileformat == 'dos'
    " XXX: line2byte() depend on 'fileformat' option.
    " so if fileformat is 'dos', 'buf' must include '\r'.
    let buf = map(buf, 'v:val."\r"')
  endif
  return buf
endfunction

function! s:Run(bin_name, source, target) abort
  let l:cmd = [a:bin_name, '-w', a:source]
  if empty(l:cmd)
    return
  endif
  let out = system(l:cmd)
  return [out, v:shell_error]
endfunction

" TODO: 用 quickfix 的方式
function! s:ShowErrors(msg) abort
  call s:echo(a:msg, 'ErrorMsg')
endfunction

function! mygo#GoFmt() abort
  let l:bin_name = 'gofmt'
  if executable(l:bin_name) != 1
    call s:ShowErrors('command not found: ' . l:bin_name)
    return
  endif

  " Save cursor position and many other things.
  let l:curw = winsaveview()

  " Write current unsaved buffer to a temp file
  let l:tmpname = tempname() . '.go'
  call writefile(s:GetLines(), l:tmpname)
  if has('win32')
    let l:tmpname = tr(l:tmpname, '\', '/')
  endif

  let current_col = col('.')
  let [l:out, l:err] = s:Run(l:bin_name, l:tmpname, expand('%'))
  let line_offset = len(readfile(l:tmpname)) - line('$')
  let l:orig_line = getline('.')

  if l:err == 0
    call s:update_file(l:tmpname, expand('%'))
  else
    let l:errors = s:replace_filename(expand('%'), out)
    call s:ShowErrors(l:errors)
  endif

  " We didn't use the temp file, so clean up
  call delete(l:tmpname)

  " Restore our cursor/windows positions.
  call winrestview(l:curw)

  " be smart and jump to the line the new statement was added/removed and
  " adjust the column within the line
  let l:lineno = line('.') + line_offset
  call cursor(l:lineno, current_col + (len(getline(l:lineno)) - len(l:orig_line)))

  " Syntax highlighting breaks less often.
  syntax sync fromstart
endfunction

" update_file updates the target file with the given formatted source
function! s:update_file(source, target)
  " remove undo point caused via BufWritePre
  try | silent undojoin | catch | endtry

  let old_fileformat = &fileformat
  if exists("*getfperm")
    " save file permissions
    let original_fperm = getfperm(a:target)
  endif

  call rename(a:source, a:target)

  " restore file permissions
  if exists("*setfperm") && original_fperm != ''
    call setfperm(a:target , original_fperm)
  endif

  " reload buffer to reflect latest changes
  silent edit!

  let &fileformat = old_fileformat
  let &syntax = &syntax
endfunction

" replace_filename replaces the filename on each line of content with
" a:filename.
function! s:replace_filename(filename, content) abort
  let l:errors = split(a:content, '\n')

  let l:errors = map(l:errors, printf('substitute(v:val, ''^.\{-}:'', ''%s:'', '''')', a:filename))
  return join(l:errors, "\n")
endfunction

" Test alternates between the implementation of code and the test code.
function! mygo#alternateSwitch(bang, cmd) abort
  let file = expand('%')
  if empty(file)
    call s:EchoError("no buffer name")
    return
  elseif file =~# '^\f\+_test\.go$'
    let l:root = split(file, '_test.go$')[0]
    let l:alt_file = l:root . ".go"
  elseif file =~# '^\f\+\.go$'
    let l:root = split(file, ".go$")[0]
    let l:alt_file = l:root . '_test.go'
  else
    call s:EchoError("not a go file")
    return
  endif
  if !filereadable(alt_file) && !bufexists(alt_file) && !a:bang
    call s:EchoError("couldn't find ".alt_file)
    return
  elseif empty(a:cmd)
    execute ":" . 'edit' . " " . alt_file
  else
    execute ":" . a:cmd . " " . alt_file
  endif
endfunction

" The message can be a list or string; every line with be :echomsg'd separately.
function! s:echo(msg, hi)
  let l:msg = []
  if type(a:msg) != type([])
    let l:msg = split(a:msg, "\n")
  else
    let l:msg = a:msg
  endif

  " Tabs display as ^I or <09>, so manually expand them.
  let l:msg = map(l:msg, 'substitute(v:val, "\t", "        ", "")')

  exe 'echohl ' . a:hi
  for line in l:msg
    echom "mygo: " . line
  endfor
  echohl None
endfunction

function! s:EchoError(msg)
  call s:echo(a:msg, 'ErrorMsg')
endfunction
