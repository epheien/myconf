#!/bin/bash
# 自动设置 linux 环境
set -e

if [ "$(uname -s)" != Linux ]; then
    echo "this script is only available under Linux"
    exit 1
fi

command -v realpath || { "realpath not found" ; exit 1; }
__file__=$(realpath "$0")
__dir__=$(dirname "$__file__")

cd "$__dir__"
if [ "$(pwd)" != "$HOME/myconf" ]; then
    echo "please clone this repo in you home diretory"
    exit 1
fi

ln -s myconf/vim ../.vim
mkdir -p ~/.config
ln -s ../.vim ~/.config/nvim

ln -s myconf/tmux/tmux.conf ../.tmux.conf

ln -s myconf/bash/inputrc ../.inputrc
ln -s myconf/bash/myshrc ../.myshrc

cat >> ~/.bashrc <<EOF

# load custom config
if [ -f ~/.myshrc ]; then
    . ~/.myshrc
fi
EOF
