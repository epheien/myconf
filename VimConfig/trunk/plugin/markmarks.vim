" Vim global plugin for make marks visible
" Last Change: 2011 Jan 17
" Maintainer: Epheien <epheien@163.com>
" License:	This file is placed in the public domain.

if exists("g:loaded_markmarks")
	finish
endif
let g:loaded_markmarks = 1


"Setting
"if !exists("g:markmarksHoldUsedMarks")
"	let g:markmarksHoldUsedMarks = 1
"endif
if !exists("g:markmarksJumpAction")
	let g:markmarksJumpAction = "'"
endif
if !exists("g:markmarksToggleMode")
	let g:markmarksToggleMode = 1
endif
if !exists("g:markmarksSignMode")
	let g:markmarksSignMode = 1
endif

if &bg == "dark"
	highlight def MarkMarks ctermfg=white ctermbg=blue guifg=white guibg=RoyalBlue3
else
	highlight def MarkMarks ctermbg=white ctermfg=blue guibg=grey guifg=RoyalBlue3
endif

let g:markmarksLowerMarks = "abcdefghijklmnopqrstuvwxyz"


if !exists("g:markmarksSignMode")
	if !hasmapto('<Plug>ToggleAutoMark', 'n')
		nmap <unique> mm <Plug>ToggleAutoMark
	endif
	if !hasmapto('<Plug>GotoNextMark', 'n')
		nmap <unique> <F2> <Plug>GotoNextMark
	endif
	if !hasmapto('<Plug>GotoPrevMark', 'n')
		nmap <unique> <S-F2> <Plug>GotoPrevMark
	endif

	if !hasmapto('<Plug>MarkMarks', 'n')
		nmap <unique> m <Plug>MarkMarks
	endif
	if !hasmapto('<Plug>MarkMarks', 'v')
		vmap <unique> m <Plug>MarkMarks
	endif

	autocmd BufWinLeave * call g:UnHiAllMarks()
	autocmd BufWinEnter * call g:HiAllMarks()
	autocmd WinEnter * call g:HiAllMarks()
else
	if !hasmapto('<Plug>Vm_toggle_sign', 'n')
		nmap <unique> mm <Plug>Vm_toggle_sign
	endif
	if !hasmapto('<Plug>Vm_goto_next_sign', 'n')
		nmap <unique> <F2> <Plug>Vm_goto_next_sign
	endif
	if !hasmapto('<Plug>Vm_goto_prev_sign', 'n')
		nmap <unique> <S-F2> <Plug>Vm_goto_prev_sign
	endif
endif

if !hasmapto('<Plug>ToggleAllHi', 'n')
	nmap <unique> mh <Plug>UnHiAllMarks
endif
if !hasmapto('<Plug>RefreshAllHi', 'n')
	nmap <unique> mr <Plug>RefreshAllHi
endif
"if !hasmapto('<Plug>ClearAllMarks', 'n')
"	nmap <unique> mc <Plug>ClearAllMarks
"endif


nnoremap <silent> <Plug>MarkMarks :call g:MarkMarks(getchar(0))<CR>
vnoremap <silent> <Plug>MarkMarks :call g:MarkMarks(getchar(0))<CR>
"nnoremap <unique> m :call g:MarkMarks(getchar(0))<CR>
"nnoremap <unique> ma :call g:MarkMarks(char2nr('a'))<CR>
nnoremap <silent> <Plug>ToggleAutoMark :call g:ToggleAutoMark()<CR>
nnoremap <silent> <Plug>ToggleAllHi :call g:ToggleAllHi()<CR>
nnoremap <silent> <Plug>RefreshAllHi :call g:HiAllMarks()<CR>
nnoremap <silent> <Plug>UnHiAllMarks :call g:UnHiAllMarks()<CR>
nnoremap <silent> <Plug>ClearAllMarks :call g:ClearAllMarks()<CR>
nnoremap <silent> <Plug>GotoNextMark :call g:GotoNextMark()<CR>
nnoremap <silent> <Plug>GotoPrevMark :call g:GotoPrevMark()<CR>

autocmd InsertLeave * if exists("w:markIDs") && !empty(w:markIDs) | call g:HiAllMarks() | endif



"===============================================================================
"===============================================================================


"最基本的变量，保存已被高亮的标记，用于删除高亮
function! s:InitVariable()
	if !exists("w:markIDs")
		let w:markIDs = {}
	endif
endf


"FIXME:没有找到“获取当前行存在的标记”的函数，只能内部解决
function! g:GenLine2mark()
	let w:line2mark = {}
	let i = char2nr('a')
	while i <= char2nr('z')
		let l:line = line("'" . nr2char(i))
		if l:line != 0
			if has_key(w:line2mark, l:line)
				let w:line2mark[l:line] = w:line2mark[l:line] . nr2char(i)
			else
				let w:line2mark[l:line] = nr2char(i)
			endif
		endif
		let i += 1
	endwhile
endf

function! g:AddMarkToLine2mark(mark)
	if !exists("w:line2mark")
		return
	endif
	let l:line = line("'" . a:mark)
	if l:line != 0
		if has_key(w:line2mark, l:line)
			let w:line2mark[l:line] = w:line2mark[l:line] . a:mark
		else
			let w:line2mark[l:line] = a:mark
		endif
	endif
endf

function! g:DelMarkFromLine2mark(mark)
	if !exists("w:line2mark")
		return
	endif
	let l:line = line("'" . a:mark)
	if l:line != 0
		if has_key(w:line2mark, l:line)
			if len(w:line2mark[l:line]) <= 1
				call remove(w:line2mark, l:line)
			else
				let w:line2mark[l:line]  = substitute(w:line2mark[l:line], '\C'.a:mark, '', '')
			endif
		endif
	endif
endf

"FIXME:不好用
function! g:IfHiMarked(line)
	let l:str = string(getmatches())
	if l:str == "[]"
		return 0
	endif

	let l:indexStart = matchend(l:str, "{'group': 'MarkMarks', 'pattern': '\\\\%" . a:line . "l', 'priority': 10, 'id': ")
	if l:indexStart == -1
		return 0
	endif

	let l:indexEnd = matchend(l:str, "{'group': 'MarkMarks', 'pattern': '\\\\%" . a:line . "l', 'priority': 10, 'id': " . '\d\+}')
	let l:len = l:indexEnd - l:indexStart - 1
	let l:id = str2nr(strpart(l:str, l:indexStart, l:len))
	echo l:id
	return l:id
endf


function! g:IfMarked(mark)
	if getpos("'" . a:mark)[1] == 0
		return 0
	else
		return 1
	endif
endf

function! g:IfNoMarked(mark)
	try
		silent exec "marks " . a:mark
	catch
		return 1
	endtry
	return 0
endf

function! g:GetLowerMarkFromLine(line)
	redir => l:msg
	silent! exec "marks " . g:markmarksLowerMarks
	redir END
"	echo l:msg
"	let l:mark = matchstr(l:msg, '\n.\{-}\n.\{-}\n\s\zs[a-z]\ze\s\+' . a:line . '\s\+\d\+')
	return matchstr(l:msg, '.\{-}\n\s\zs[a-z]\ze\s\+'.a:line.'\s\+\d\+')
endf

"仅负责删除已经被自己插件高亮了的标记，如果没有高亮，则什么都不做
"仅仅对 w:markIDs 记录的标记操作
function! g:DelMark(mark)
	call s:InitVariable()
	if has_key(w:markIDs, a:mark)
		exec "delmarks " . a:mark
		call matchdelete(w:markIDs[a:mark])
		call remove(w:markIDs, a:mark)
	endif
endf

"仅负责添加指定标记，会处理已使用的标记
"需要最基本的数据结构 markIDs，保存已被高亮的标记
function! g:AddMark(mark)
	if g:IfMarked(a:mark)
		call g:DelMark(a:mark)
	endif
	call s:InitVariable()
	exec "normal! m" . a:mark
	let w:markIDs[a:mark] = matchadd("MarkMarks", '\%' . line('.') . 'l', -15)
endf

function! g:DelAllMarks()
	call s:InitVariable()
	for key in keys(w:markIDs)
		exec "delmarks " . key
		call matchdelete(w:markIDs[key])
		call remove(w:markIDs, key)
	endfor
endf

function! g:HiAllMarks()
	call g:UnHiAllMarks()

	if g:IfNoMarked(g:markmarksLowerMarks)
		return
	endif

	let i = char2nr('a')
	while i <= char2nr('z')
		if g:IfMarked(nr2char(i))
			let w:markIDs[nr2char(i)] = matchadd("MarkMarks", '\%' . line( "'" . nr2char(i)) . 'l', -15)
		endif
		let i += 1
	endwhile
endf

function! g:UnHiAllMarks()
	call s:InitVariable()
	for key in keys(w:markIDs)
		call matchdelete(w:markIDs[key])
		call remove(w:markIDs, key)
	endfor
endf

function! g:ToggleAllHi()
	if !exists("w:markIDs")
		call g:HiAllMarks()
	elseif empty(w:markIDs)
		call g:HiAllMarks()
	else
		call g:UnHiAllMarks()
	endif
endf

"仅仅负责添加 mark，不负责切换
function! g:MarkMarks(charnr)
	if exists("g:markmarksToggleMode")
		if a:charnr >= char2nr('A') && a:charnr <= char2nr('Z')
			exec "normal! m" . nr2char(a:charnr)
		endif
		return
	endif

	if a:charnr < char2nr('a') || a:charnr > char2nr('z')
		return
	endif

	let l:mark = nr2char(a:charnr)
	call g:AddMark(l:mark)
endf


function! g:InitMarkQueue()
	if exists("w:markQueueIndex")
		return
	endif

	let w:markQueue = []
	let w:markQueueUsed = []
	let w:markQueueIndex = 0

	let i = char2nr('a')
	while i <= char2nr('z')
		if exists("g:markmarksHoldUsedMarks") || exists("g:markmarksContinueToggle")
			if g:IfMarked(nr2char(i))
				call add(w:markQueueUsed, nr2char(i))
			else
				call add(w:markQueue, nr2char(i))
			endif
		elseif exists("g:markmarksContinueToggle")
			call extend(w:markQueue, w:markQueueUsed)
		else
			call add(w:markQueue, nr2char(char2nr('z') - i + char2nr('a')))
		endif
		let i += 1
	endwhile
endf

"需要 w:markQueue 支持
function! g:AddAutoMark()
	call g:InitMarkQueue()
	call g:AddMark(w:markQueue[w:markQueueIndex])
	let l:mark = w:markQueue[w:markQueueIndex]
	let w:markQueueIndex = (w:markQueueIndex + 1) % len(w:markQueue)
	return l:mark
endf

"需要 w:markQueue 和 w:line2mark 支持
function! g:ToggleAutoMark()
	if exists("w:markIDs") && !empty(w:markIDs)
		let g:markmarksContinueToggle = 1
	endif

	if !exists("g:markmarksToggleMode") && !exists("g:markmarksContinueToggle")
		call g:ClearAllMarks()
	endif

	if !exists("w:line2mark")
		call g:GenLine2mark()
	endif

	let l:curline = line('.')
	if has_key(w:line2mark, l:curline)
		for i in range(len(w:line2mark[l:curline]))
			call g:DelMark(w:line2mark[l:curline][i])
		endfor
		call remove(w:line2mark, l:curline)
	else
		call g:InitMarkQueue()
		call g:DelMarkFromLine2mark(w:markQueue[w:markQueueIndex])
		let l:mark = g:AddAutoMark()
		call g:AddMarkToLine2mark(l:mark)
	endif
endf

"无责任清理所有[a-z]的标记以及高亮
function! g:ClearAllMarks()
	call g:DelAllMarks()
	delmarks!
	"clear w:line2mark
	let w:line2mark = {}
endf

function! g:GotoNextMark()
	if g:IfNoMarked(g:markmarksLowerMarks)
		return
	endif

	if g:markmarksJumpAction == "'"
		let w:lastTimeNext = line('.')
		exec "normal! ]'"
		"假设第一行第一列有一个标记，所以处理复杂了一点
		if line('.') == w:lastTimeNext
			call g:GenLine2mark()
			let l:list = keys(w:line2mark)
			if len(l:list) == 1
				exec l:list[0]
				return
			else
				mark '
				exec min(l:list)
			endif
"			exec "normal! ggj"
"			exec "keepjumps normal! ['"
"			if line('.') == 2
"				exec "keepjumps normal! gg"
"				exec "keepjumps normal! ]'"
"			else
"				exec "keepjumps normal! $"
"				exec "keepjumps normal! ['"
"			endif
"			exec "normal! zt"
		endif
	else
	endif
endf

function! g:GotoPrevMark()
	if g:IfNoMarked(g:markmarksLowerMarks)
		return
	endif

	if g:markmarksJumpAction == "'"
		let w:lastTimePrev = line('.')
		exec "normal! ['"
		if line('.') == w:lastTimePrev
			call g:GenLine2mark()
			let l:list = keys(w:line2mark)
			if len(l:list) == 1
				exec l:list[0]
				return
			else
				mark '
				exec max(l:list)
			endif
"			exec "normal! Gk"
"			exec "keepjumps normal! ]'"
"			if line('.') == line('$') - 1
"				exec "keepjumps normal! G"
"				exec "keepjumps normal! ['"
"			else
"				exec "keepjumps normal! 0"
"				exec "keepjumps normal! ]'"
"			endif
		endif
	else
	endif
endf



"===============================================================================
"===============================================================================
"Merge visualmark by epheien

if !has("signs")
 echoerr "***sorry*** [".expand("%")."] your vim doesn't support signs"
 finish
endif

if &bg == "dark"
" highlight SignColor ctermfg=white ctermbg=blue guifg=white guibg=RoyalBlue3
 "MOD
 "highlight SignColor ctermfg=white ctermbg=blue
else
 highlight SignColor ctermbg=white ctermfg=blue guibg=grey guifg=RoyalBlue3
endif
"MODs
if &bg == "dark"
 highlight SignTextColor ctermfg=white guifg=white
else
 highlight SignTextColor ctermfg=blue guifg=grey
endif

" ---------------------------------------------------------------------
"  Public Interface:
"  MODs
"if !hasmapto('<Plug>Vm_toggle_sign')
"  map <unique> <C-F2> <Plug>Vm_toggle_sign
"  map <silent> <unique> mm <Plug>Vm_toggle_sign 
"endif
"nnoremap <unique> <silent> <C-F2> :call Vm_toggle_sign()<cr>
"nnoremap <silent> mm :call Vm_toggle_sign()<cr>

"if !hasmapto('<Plug>Vm_goto_next_sign')
"  map <unique> <F2> <Plug>Vm_goto_next_sign
"endif

"if !hasmapto('<Plug>Vm_goto_prev_sign')
"  map <unique> <s-F2> <Plug>Vm_goto_prev_sign
"endif

nnoremap <silent> <Plug>Vm_toggle_sign :call Vm_toggle_sign()<cr>
nnoremap <silent> <script> <Plug>Vm_goto_prev_sign	:call Vm_goto_prev_sign()<cr>
nnoremap <silent> <script> <Plug>Vm_goto_next_sign	:call Vm_goto_next_sign()<cr>

" ---------------------------------------------------------------------
"  GetVimCmdOutput:
" Stole from Hari Krishna Dara's genutils.vim (http://vim.sourceforge.net/scripts/script.php?script_id=197)
"  to ease the scripts dependency issue
fun! s:GetVimCmdOutput(cmd)
"  call Dfunc("GetVimCmdOutput(cmd.".a:cmd.">)")

  " Save the original locale setting for the messages
  let old_lang = v:lang

  " Set the language to English
  exec ":lan mes en_US.UTF-8"

  let v:errmsg = ''
  let output   = ''
  let _z       = @z

  try
    redir @z
    silent exe a:cmd
  catch /.*/
    let v:errmsg = substitute(v:exception, '^[^:]\+:', '', '')
  finally
    redir END
    if v:errmsg == ''
      let output = @z
    endif
    let @z = _z
  endtry

  " Restore the original locale
  exec ":lan mes " . old_lang

"  call Dret("GetVimCmdOutput <".output.">")
  return output
endfun

" ---------------------------------------------------------------------
"  Vm_place_sign:
fun! s:Vm_place_sign()
"  call Dfunc("Vm_place_sign()")

  if !exists("b:Vm_sign_number")
    let b:Vm_sign_number = 1
  endif

  let ln = line(".")

  exe 'sign define SignSymbol linehl=SignColor texthl=SignTextColor text=>>'
  exe 'sign place ' . b:Vm_sign_number . ' line=' . ln . ' name=SignSymbol buffer=' . winbufnr(0)

  let vsn              = b:Vm_sign_number
  let b:Vm_sign_number = b:Vm_sign_number + 1

"  call Dret("Vm_place_sign : sign#".vsn." line#".ln." buf#".winbufnr(0))
endfun

" ---------------------------------------------------------------------
" Vm_remove_sign:
fun! s:Vm_remove_sign(sign_id)
"  call Dfunc("Vm_remove_sign(sign_id=".a:sign_id.")")
  silent! exe 'sign unplace ' . a:sign_id . ' buffer=' . winbufnr(0)
"  call Dret("Vm_remove_sign")
endfun

" ---------------------------------------------------------------------
" Vm_remove_all_signs:
fun! s:Vm_remove_all_signs()
"  call Dfunc("Vm_remove_all_signs()")
  silent! exe 'sign unplace *'
"  call Dret("Vm_remove_all_signs")
endfun

" ---------------------------------------------------------------------
" Vm_get_sign_id_from_line:
fun! s:Vm_get_sign_id_from_line(line_number)
"  call Dfunc("Vm_get_sign_id_from_line(line_number=".a:line_number.")")

  let sign_list = s:GetVimCmdOutput('sign place buffer=' . winbufnr(0))
"  call Decho(sign_list)

  let line_str_index = match(sign_list, "line=" . a:line_number, 0)
  if line_str_index < 0
"    call Dret("Vm_get_sign_id_from_line -1")
    return -1
  endif

  let id_str_index = matchend(sign_list, "id=", line_str_index)
"  let tmp = strpart(sign_list, id_str_index, 10)   "Decho
"  call Decho("ID str index: " . tmp)
  if id_str_index < 0
"    call Dret("Vm_get_sign_id_from_line -1")
    return -1
  endif

  let space_index = match(sign_list, " ", id_str_index)
  let id          = strpart(sign_list, id_str_index, space_index - id_str_index)

"  call Dret("Vm_get_sign_id_from_line ".id)
  return id
endfun

" ---------------------------------------------------------------------
" Vm_toggle_sign:
fun! Vm_toggle_sign()
"  call Dfunc("Vm_toggle_sign()")

  let curr_line_number = line(".")
  let sign_id          = s:Vm_get_sign_id_from_line(curr_line_number)

  if sign_id < 0
    let is_on = 0
  else
    let is_on = 1
  endif

  if (is_on != 0)
    call s:Vm_remove_sign(sign_id)
  else
    call s:Vm_place_sign()
  endif

"  call Dret("Vm_toggle_sign")
endfun

" ---------------------------------------------------------------------
" Vm_get_line_number:
fun! s:Vm_get_line_number(string)
"  call Dfunc("Vm_get_line_number(string<".a:string.">)")

  let line_str_index = match(a:string, "line=", b:Vm_start_from)
  if line_str_index <= 0
"    call Dret("Vm_get_line_number -1")
    return -1
  endif

  let equal_sign_index = match(a:string, "=", line_str_index)
  let space_index      = match(a:string, " ", equal_sign_index)
  let line_number      = strpart(a:string, equal_sign_index + 1, space_index - equal_sign_index - 1)
  let b:Vm_start_from  = space_index

"  call Dret("Vm_get_line_number ".line_number." : =indx:".equal_sign_index." _indx=".space_index)
  return line_number + 0
endfun

" ---------------------------------------------------------------------
" Vm_get_next_sign_line:
fun! s:Vm_get_next_sign_line(curr_line_number)
  " call Dfunc("Vm_get_next_sign_line(curr_line_number=".a:curr_line_number.">)")

  let b:Vm_start_from = 1
  let sign_list = s:GetVimCmdOutput('sign place buffer=' . winbufnr(0))
  " call Decho("sign_list<".sign_list.">")

  let curr_line_number = a:curr_line_number
  let line_number = 1
  let is_no_sign  = 1
  let min_line_number = -1
  let min_line_number_diff = 0
  
  while 1
    let line_number = s:Vm_get_line_number(sign_list)
    if line_number < 0
      break
    endif

    " Record the very first line that has a sign
    if is_no_sign != 0 
      let min_line_number = line_number
    elseif line_number < min_line_number
      let min_line_number = line_number
    endif
    let is_no_sign = 0

    " let tmp_diff = curr_line_number - line_number
    let tmp_diff = line_number - curr_line_number
    if tmp_diff > 0
      " line_number is below curr_line_number
      if min_line_number_diff > 0 
        if tmp_diff < min_line_number_diff
          let min_line_number_diff = tmp_diff
        endif
      else
        let min_line_number_diff = tmp_diff
      endif
    endif

    " call Decho("[DBG] Line Diff: #" . min_line_number_diff)
  endwhile

  let line_number = curr_line_number + min_line_number_diff
  " call Decho("[DBG] Line Diff: #" . min_line_number_diff)
  " call Decho("[DBG] Line Num: #" . line_number)

  if is_no_sign != 0 || min_line_number_diff <= 0
    let line_number = min_line_number
  endif

  " call Dret("Vm_get_next_sign_line ".line_number . " XXX")
  return line_number
endfun

" ---------------------------------------------------------------------
" Vm_get_prev_sign_line:
fun! s:Vm_get_prev_sign_line(curr_line_number)
  " call Dfunc("Vm_get_prev_sign_line(curr_line_number=".a:curr_line_number.">)")

  let b:Vm_start_from = 1
  let sign_list = s:GetVimCmdOutput('sign place buffer=' . winbufnr(0))
  " call Decho("sign_list<".sign_list.">")

  let curr_line_number = a:curr_line_number
  let line_number = 1
  let is_no_sign  = 1
  let max_line_number = -1
  let max_line_number_diff = 0
  
  while 1
    let line_number = s:Vm_get_line_number(sign_list)
    if line_number < 0
      break
    endif

    " Record the very first line that has a sign
    if is_no_sign != 0 
      let max_line_number = line_number
    elseif line_number > max_line_number 
      let max_line_number = line_number
    endif
    let is_no_sign = 0

    let tmp_diff = curr_line_number - line_number
    if tmp_diff > 0
      " line_number is below curr_line_number
      if max_line_number_diff > 0 
        if tmp_diff < max_line_number_diff 
          let max_line_number_diff = tmp_diff
        endif
      else
        let max_line_number_diff = tmp_diff
      endif
    endif

    " call Decho("[DBG] Line Diff: #" . max_line_number_diff)
    " call Decho("[DBG] Tmp Diff: #" . tmp_diff)
  endwhile

  let line_number = curr_line_number - max_line_number_diff 
  " call Decho("[DBG] Line Diff: #" . max_line_number_diff)
  " call Decho("[DBG] Line Num: #" . line_number)

  if is_no_sign != 0 || max_line_number_diff <= 0
    let line_number = max_line_number 
  endif

  " call Dret("Vm_get_prev_sign_line ".line_number . " XXX")
  return line_number
endfun

" ---------------------------------------------------------------------
" Vm_goto_next_sign:
fun! Vm_goto_next_sign()
  " call Dfunc("Vm_goto_next_sign()")

  let curr_line_number      = line(".")
  let next_sign_line_number = s:Vm_get_next_sign_line(curr_line_number)

"  call Decho("Next sign line #:  " . next_sign_line_number)
  if next_sign_line_number >= 0
    exe ":" . next_sign_line_number
    "call Decho("Going to Line #" . next_sign_line_number)
  endif

"  call Dret("Vm_goto_next_sign")
endfun

" ---------------------------------------------------------------------
" Vm_goto_prev_sign:
fun! Vm_goto_prev_sign()
  " call Dfunc("Vm_goto_prev_sign()")

  let curr_line_number      = line(".")
  let prev_sign_line_number = s:Vm_get_prev_sign_line(curr_line_number)
"  call Decho("Previous sign line #:  " . prev_sign_line_number)

  if prev_sign_line_number >= 0
    exe prev_sign_line_number 
  endif

  " call Dret("Vm_goto_prev_sign")
endfun

" ---------------------------------------------------------------------

