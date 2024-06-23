#!/bin/bash
# 打包所有插件以用于一键在新环境安装全套插件
set -e
output=vim-plugins.tar.gz
tar --no-mac-metadata --no-xattrs -czf "$output" pckr/ plugged/
echo "Done: $output"
