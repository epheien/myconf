" 实现基本的 cpp 插件功能, 切换头/源文件是必须的

let s:file = expand('<sfile>')
let s:mod = fnamemodify(s:file, ':t:r')
let s:header_exts = ['hpp', 'hxx', 'hh', 'h']
let s:source_exts = ['cpp', 'cxx', 'cc', 'c']

function! mycpp#alternateSwitch(bang, cmd) abort
  let file = expand('%')
  if empty(file)
    call s:EchoError("no buffer name")
    return
  endif
  let ext = fnamemodify(file, ':e')
  " 不包含路径和扩展的文件名
  let root = fnamemodify(file, ':t:r')
  let directory = fnamemodify(file, ':h')
  let files = mycpp#GetProjectFiles()
  let is_header = v:false
  if index(s:source_exts, ext) >= 0
    " source => header
    let alt_exts = s:header_exts
  elseif index(s:header_exts, ext) >= 0
    " header => source
    let alt_exts = s:source_exts
    let is_header = v:true
  else
    call s:EchoError("not a cpp file")
    return
  endif
  for ext in alt_exts
    " 不包含前置路径的文件名
    if is_header
      let alt_file = mycpp#FindSource(files, directory, root, ext)
    else
      let alt_file = mycpp#FindHeader(files, directory, root, ext)
    endif
    if empty(alt_file)
      continue
    endif
    if !filereadable(alt_file) && !bufexists(alt_file) && !a:bang
      call s:EchoError("couldn't find ".alt_file)
      return
    elseif empty(a:cmd)
      execute ":" . 'edit' . " " . alt_file
    else
      execute ":" . a:cmd . " " . alt_file
    endif
    break
  endfor
endfunction

function! s:NormPath(path) abort
  return substitute(a:path, '^\./', '', '')
endfunction

function! s:CheckFileExists(files, fpath) abort
  let fpath = a:fpath
  if a:files isnot v:null
    let idx = index(a:files, fpath)
    if idx < 0
      return v:false
    endif
  endif
  " TODO
  "return v:true
  if !filereadable(fpath) && !bufexists(fpath)
    return v:false
  endif
  return v:true
endfunction

" 返回带前置路径的源文件
"   @files: 在此文件列表里面查找, 可以为相对路径也可以为绝对路径
"     如果为 v:null, 则表示直接从文件系统里面找
"   @directory: root 所在的目录, 可以为相对路径也可以为绝对路径
"   @root: 不包含路径和扩展名的文件名
"   @ext: 目标源码的后缀名
function! mycpp#FindSource(files, directory, root, ext) abort
  let basename = printf("%s.%s", a:root, a:ext)
  let folder = a:directory

  " 找出所有匹配 basename 的结果
  let files = a:files
  if files isnot v:null
    let files = filter(copy(a:files), {idx, val -> fnamemodify(val, ':t') ==# basename})
  endif

  " 优先处理 当前目录 以及 include/ => src/
  let fpath = s:NormPath(printf('%s/%s', folder, basename))
  if s:CheckFileExists(files, fpath)
    return fpath
  endif
  if fnamemodify(folder, ':t') ==# 'include'
    let fpath = s:NormPath(fnamemodify(folder, ':h') . '/src/' . basename)
    if s:CheckFileExists(files, fpath)
      return fpath
    endif
  endif

  if files isnot v:null && empty(files)
    return ''
  endif

  let tmpfolder = folder
  " 逐层正则匹配
  for i in range(3)
    if i > 0
      let tmpfolder = fnamemodify(tmpfolder, ':h')
    endif
    if tmpfolder == '.'
      if s:CheckFileExists(v:null, files[0])
        return files[0]
      else
        return ''
      endif
    endif

    if files is v:null
      let fpath = s:NormPath(printf('%s/%s', tmpfolder, basename))
      if s:CheckFileExists(v:null, fpath)
        return fpath
      endif
      continue
    endif

    " 从文件列表里面按照正则查找
    for file in files
      " 匹配前置路径, 只要找到就算
      if file =~# '\V\^' . escape(tmpfolder, '\') . '\($\|/\)'
        if s:CheckFileExists(v:null, file)
          return file
        endif
      endif
    endfor
  endfor

  return ''
endfunction

" 返回带前置路径的源文件
"   @files: 在此文件列表里面查找, 可以为相对路径也可以为绝对路径
"     如果为 v:null, 则表示直接从文件系统里面找
"   @directory: root 所在的目录, 可以为相对路径也可以为绝对路径
"   @root: 不包含路径和扩展名的文件名
"   @ext: 目标源码的后缀名
function! mycpp#FindHeader(files, directory, root, ext) abort
  let basename = printf("%s.%s", a:root, a:ext)
  let folder = a:directory

  " 找出所有匹配 basename 的结果
  let files = a:files
  if files isnot v:null
    let files = filter(copy(a:files), {idx, val -> fnamemodify(val, ':t') ==# basename})
  endif

  " 优先处理 当前目录 以及 src/ => include/
  let fpath = s:NormPath(printf('%s/%s', folder, basename))
  if s:CheckFileExists(files, fpath)
    return fpath
  endif
  if fnamemodify(folder, ':t') ==# 'src'
    let fpath = s:NormPath(fnamemodify(folder, ':h') . '/include/' . basename)
    if s:CheckFileExists(files, fpath)
      return fpath
    endif
  endif

  if files isnot v:null && empty(files)
    return ''
  endif

  let tmpfolder = folder
  " 逐层正则匹配
  for i in range(3)
    if i > 0
      let tmpfolder = fnamemodify(tmpfolder, ':h')
    endif
    if tmpfolder == '.'
      if s:CheckFileExists(v:null, files[0])
        return files[0]
      else
        return ''
      endif
    endif

    if files is v:null
      let fpath = s:NormPath(printf('%s/%s', tmpfolder, basename))
      if s:CheckFileExists(v:null, fpath)
        return fpath
      endif
      continue
    endif

    " 从文件列表里面按照正则查找
    for file in files
      " 匹配前置路径, 只要找到就算
      if file =~# '\V\^' . escape(tmpfolder, '\') . '\($\|/\)'
        if s:CheckFileExists(v:null, file)
          return file
        endif
      endif
    endfor
  endfor

  return ''
endfunction

" 获取项目文件列表, 当前直接从 gtags.files 读取
function! mycpp#GetProjectFiles()
  let fname = 'gtags.files'
  if !filereadable(fname)
    return []
  endif
  return readfile(fname)
endfunction

function! s:EchoError(msg)
  call s:echo(a:msg, 'ErrorMsg')
endfunction

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
    echom s:mod . ": " . line
  endfor
  echohl None
endfunction
