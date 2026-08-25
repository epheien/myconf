#!/bin/bash
# 自动设置 linux 环境
# nvim 下载地址: https://github.com/neovim/neovim/releases/download/v0.8.3/nvim.appimage
set -e

if [ "$(uname -s)" != Linux ]; then
    echo "this script is only available under Linux"
    exit 1
fi

command -v realpath >/dev/null || { echo "realpath not found" ; exit 1; }
__file__=$(realpath "$0")
__dir__=$(dirname "$__file__")

cd "$__dir__"
if [ "$(pwd)" != "$HOME/myconf" ]; then
    echo "please clone this repo in you home diretory"
    exit 1
fi

# 幂等创建软链接: 是软链接则删除重建, 真实文件/目录则跳过
link() {
    local src="$1" dest="$2"
    if [ -L "$dest" ]; then
        rm -f "$dest"
        ln -s "$src" "$dest"
        echo "relink: $dest -> $src"
    elif [ -e "$dest" ]; then
        echo "skip: $dest exists and is not a symlink"
    else
        ln -s "$src" "$dest"
        echo "link: $dest -> $src"
    fi
}

link myconf/vim ../.vim
mkdir -p ~/.config
link ../.vim ~/.config/nvim

link myconf/tmux/tmux.conf ../.tmux.conf

link myconf/bash/inputrc ../.inputrc
link myconf/bash/myshrc ../.myshrc

if ! grep -qF "# load custom config" ~/.bashrc 2>/dev/null; then
    cat >> ~/.bashrc <<'EOF'

# load custom config
if [ -f ~/.myshrc ]; then
    . ~/.myshrc
fi
EOF
fi
