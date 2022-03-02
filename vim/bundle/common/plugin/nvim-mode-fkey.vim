" nvim 的 Shift-<F1-F12> 实际键码为 <F13-F24>, 所以需要重新映射

if has('nvim')
    for n in ['', 'l', 't']
        for i in range(13, 24)
            execute printf('%smap <F%s> <S-F%s>', n, i, i-12)
        endfor
    endfor
endif
