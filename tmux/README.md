# tmux

## macOS 安装 tmux-256color terminfo
可解决 tmux + oh-my-zsh 的各种按键问题
```sh
curl -LO https://invisible-island.net/datafiles/current/terminfo.src.gz && gunzip terminfo.src.gz
/usr/bin/tic -xe tmux-256color terminfo.src
```

ref: https://gist.github.com/bbqtd/a4ac060d6f6b9ea6fe3aabe735aa9d95
