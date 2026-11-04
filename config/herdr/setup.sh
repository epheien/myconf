#!/bin/bash
# herdr: https://github.com/herdr/herdr
# 只链接 config.toml，因为 ~/.config/herdr 里还有运行时文件
# (sock / log / session.json / session-snapshots)

script_path=$(realpath "$0")
script_dir=$(dirname "$script_path")

config_dir=~/.config/herdr
target="$config_dir/config.toml"

mkdir -p "$config_dir"

# herdr 首次运行会自动生成默认 config.toml，先备份已有配置
if [ -e "$target" ] && [ ! -L "$target" ]; then
    mv -v "$target" "$target.bak"
fi

ln -sfv "$script_dir/config.toml" "$target"
