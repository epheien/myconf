## Requirements
    pip3 install pynvim

## 参考资料

### iTerm 的 gruvbox-dark 主题配色
```vimscript
function g:ItermGruvboxDarkTheme()
    " iTerm2 的 gruvbox-dark 主题
    " 但是一般勾选"Brighten bold text", 颜色就跟这个不一致了
    let g:terminal_color_0 = '#272727'
    let g:terminal_color_8 = '#928378'

    let g:terminal_color_1 = '#cc231c'
    let g:terminal_color_9 = '#fb4833'

    let g:terminal_color_2 = '#989719'
    let g:terminal_color_10 = '#b8ba25'

    let g:terminal_color_3 = '#d79920'
    let g:terminal_color_11 = '#fabc2e'

    let g:terminal_color_4 = '#448488'
    let g:terminal_color_12 = '#83a597'

    let g:terminal_color_5 = '#b16185'
    let g:terminal_color_13 = '#d3859a'

    let g:terminal_color_6 = '#689d69'
    let g:terminal_color_14 = '#8ec07b'

    let g:terminal_color_7 = '#a89983'
    let g:terminal_color_15 = '#ebdbb2'
endfunction
```
