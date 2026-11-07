#!/bin/bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "Skipping terminfo setup (macOS only)."
    exit 0
fi

script_dir="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
target_dir="$HOME/.terminfo"

mkdir -p "$target_dir"

for source_file in "$script_dir"/*.src; do
    [[ -f "$source_file" ]] || continue
    # 使用 macOS 自带 tic，并保留 smxx 等扩展能力。
    /usr/bin/tic -x -o "$target_dir" "$source_file"
    printf 'Installed %s -> %s\n' "$(basename -- "$source_file")" "$target_dir"
done
