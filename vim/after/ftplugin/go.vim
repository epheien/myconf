if exists("b:did_after_ftplugin")
  finish
endif
let b:did_after_ftplugin = 1

setlocal shiftwidth=4
setlocal softtabstop=-1
setlocal tabstop=4
setlocal expandtab&

nnoremap <buffer> <silent> [[ :<C-U>call <SID>BlockJumpPrev()<CR>

" NOTE: 无法分辨是否嵌套, 只会无脑往前搜索指定的 go 语法模式
function! s:BlockJumpPrev() abort
  call search('^[a-zA-Z_]\+.\+{$', 'bWs')
endfunction

" 实现代码取自 vim-go 并精简
command -buffer GoFmt call s:GoFmt()

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

" TODO: 需要支持 quickfix
function! s:ShowErrors(msg) abort
  echohl Error
  echomsg a:msg
  echohl None
endfunction

function! s:GoFmt() abort
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
