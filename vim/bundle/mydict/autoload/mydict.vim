" 自用 stardict 插件，依赖 sdcv (https://github.com/Dushistov/sdcv)

if exists('s:loaded') || !exists('*getjumplist')
  finish
endif
let s:loaded = 1

func mydict#esc4menu(s)
    return substitute(escape(a:s, '. \' . "\t"), '&', '&&', 'g')
endfunc

" 弹出菜单，支持多行
func mydict#popup(msg)
    if type(a:msg) == v:t_string
        let lines = split(a:msg, "\n")
    else
        let lines = a:msg
    endif
    if empty(lines)
        return
    endif
    silent! aunmenu ]mydict
    let done = 0
    for line in lines
        if empty(line)
            continue
        endif
        exec 'anoremenu' ']mydict.'.mydict#esc4menu(line) '<Nop>'
        let done = 1
    endfor
    if done
        " BUG: 选择菜单的时候，会报错
        silent! popup ]mydict
    endif
endfunc

func mydict#Search(word)
    let out = system('sdcv -nj ' . shellescape(a:word))
    let data = json_decode(out)
    if empty(data)
        return
    endif
    let res = data[0]
    let word = get(res, 'word', '')
    let dict = get(res, 'dict', '')
    if !empty(dict)
        let lines = [printf('%s [%s]', word, dict)]
    else
        let lines = [word]
    endif
    for line in split(get(res, 'definition', ''), "\n")
        call add(lines, ' ' . line)
    endfor
    let num = min([&lines - 2, len(lines)])
    call filter(lines, {idx, val -> idx < num})
    call mydict#popup(lines)
endfunc
