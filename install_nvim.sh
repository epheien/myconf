#!/bin/bash
# 自动安装最新的稳定版 nvim (neovim), 安装到 ~/opt/nvim-$kernel-$arch 目录
set -e

# 1. 创建必要的目录
mkdir -p ~/opt ~/bin

# 2. 进入 opt 目录
cd ~/opt

kernel=linux
if [ $(uname -s) != "Linux" ]; then
    kernel=macos
fi
arch=$(uname -m)

wget -c https://github.com/neovim/neovim/releases/latest/download/nvim-$kernel-$arch.tar.gz -O nvim-$kernel-$arch.tar.gz
rm -rf ~/opt/nvim-$kernel-$arch/
tar -xf nvim-$kernel-$arch.tar.gz
[ ! -e ~/bin/nvim -o -L ~/bin/nvim ] && ln -sfv ~/opt/nvim-$kernel-$arch/bin/nvim ~/bin/
rm -f nvim-$kernel-$arch.tar.gz

# NOTE: macOS 系统下如果不能运行, 执行: xattr -d com.apple.quarantine ~/bin/nvim
