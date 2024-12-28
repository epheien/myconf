# Vim / Neovim Configuration

## Requirements
    pip3 install pynvim

## TODO
- [X] 支持鼠标拖动浮动窗口
- [X] nvim-cmp 以及 cmp-cmdline 插件在命令行粘贴命令的时候, 好像有性能问题
- [ ] `setl nowra` 无法补全, 因为原版是以 `setl no` 作为起点匹配补全的
- [x] `:h<CR>:Outline<CR>:OutlineStatus<CR>` 背景色会变化, 非常奇怪 (用 vim.opt_local 能解决这个问题)

## 参考资料

### iTerm 的 gruvbox-dark 主题配色
```vim
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

" 跟 iTerm2 实际效果还是有区别, 考虑用其他主题
function! g:BrightenBoldText() abort
    for i in range(8)
        let tmp = g:terminal_color_{i}
        let g:terminal_color_{i} = g:terminal_color_{i+8}
        let g:terminal_color_{i+8} = tmp
    endfor
endfunction
```
