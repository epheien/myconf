#!/bin/bash
# 打包所有插件以用于一键在新环境安装全套插件
set -e
output=vim-plugins.tar.gz

if [ -d /proc/ ]; then
    cmd="tar --no-xattrs"
else
    cmd="tar --no-mac-metadata --no-xattrs"
fi

# -m means minimize
if [ "$1" == "-m" ]; then
    cmd="$cmd --exclude 'coc/*' --exclude '*/coc.nvim/*' --exclude videm --exclude '*/vimcdoc/*'"
fi

eval $cmd -czf "$output" pckr/ plugged/ coc/

echo "Done: $output"
