#!/usr/bin/env bash
# 安装/合并 myconf 的 codex 默认配置
#   新环境(无 config.toml): 直接复制模板
#   已有 config.toml:       合并模板, 保留 codex 自动写入的状态 (projects、hooks.state 等)
# 依赖: bash、POSIX awk、cmp、diff。可重复执行(幂等)。
set -euo pipefail

# 脚本所在目录
script_dir="$(dirname "${BASH_SOURCE[0]}")"
tpl="$script_dir/config.toml"
merge_awk="$script_dir/merge.awk"
deprecated="personality"

for f in "$tpl" "$merge_awk"; do
    [ -f "$f" ] || { echo "error: missing $f" >&2; exit 1; }
done
command -v awk >/dev/null 2>&1 || { echo "error: awk not found" >&2; exit 1; }

codex_home="${CODEX_HOME:-$HOME/.codex}"
target="$codex_home/config.toml"
mkdir -p "$codex_home"

if [ ! -s "$target" ]; then
    cp "$tpl" "$target"
    echo "created: $target"
else
    tmp=$(mktemp "${TMPDIR:-/tmp}/codex-config.XXXXXX")
    trap 'rm -f "$tmp"' EXIT

    awk -v tpl="$tpl" -v dep="$deprecated" -f "$merge_awk" "$target" > "$tmp"

    if cmp -s "$target" "$tmp"; then
        echo "unchanged: $target"
    else
        cp -p "$target" "$target.bak"
        cat "$tmp" > "$target"
        echo "updated: $target"
        echo "backup:  $target.bak"
        diff -u "$target.bak" "$target" || true
    fi
fi

if ! command -v codex >/dev/null 2>&1; then
    echo
    echo "note: codex not found in PATH. install it with:"
    echo "  npm install -g @openai/codex"
fi
