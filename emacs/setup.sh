#!/bin/sh
# 将仓库中的 init.el 链接到 Emacs 的启动目录。
set -eu

script_path=$(realpath "$0")
source_file="$(dirname "$script_path")/init.el"
emacs_dir="${HOME:?}/.emacs.d"
link="$emacs_dir/init.el"

if [ ! -f "$source_file" ]; then
    printf '找不到配置文件 %s\n' "$source_file" >&2
    exit 1
fi

if [ -L "$link" ] && [ "$link" -ef "$source_file" ]; then
    printf '配置链接 %s 已就绪。\n' "$link"
    exit 0
fi

if [ -e "$link" ] || [ -L "$link" ]; then
    printf '%s 已被其他配置占用，请先将它移到备份位置再运行。\n' "$link" >&2
    exit 1
fi

mkdir -p "$emacs_dir"
ln -s "$source_file" "$emacs_dir/"
printf '已链接 %s -> %s\n' "$link" "$source_file"
