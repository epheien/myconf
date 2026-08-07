#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
OMP_HOME="$HOME/.omp"

link() {
	local src="$1" dst="$2"
	if [ -e "$dst" ] && [ ! -L "$dst" ]; then
		echo "WARN: $dst 已存在且不是软链接，跳过" >&2
		return
	fi
	mkdir -p "$(dirname "$dst")"
	ln -sfn "$src" "$dst"
	echo "  OK  $dst -> $src"
}

link_opt() {
	local src="$1" dst="$2"
	if [ -e "$src" ] || [ -L "$src" ]; then
		link "$src" "$dst"
	else
		echo "  SKIP $src 不存在"
	fi
}

echo "==> 创建软链接到 ~/.omp/ ..."

link "$REPO_DIR/agent/mcp.json"   "$OMP_HOME/agent/mcp.json"
link "$REPO_DIR/agent/ssh.json"   "$OMP_HOME/agent/ssh.json"
link "$REPO_DIR/agent/themes"     "$OMP_HOME/agent/themes"
link "$REPO_DIR/agent/tools"      "$OMP_HOME/agent/tools"
link "$REPO_DIR/agent/commands"   "$OMP_HOME/agent/commands"
link "$REPO_DIR/agent/prompts"    "$OMP_HOME/agent/prompts"
link "$REPO_DIR/agent/modules"    "$OMP_HOME/agent/modules"
link "$REPO_DIR/plugins"          "$OMP_HOME/plugins"

link_opt "$REPO_DIR/agent.db"     "$OMP_HOME/agent/agent.db"
link_opt "$REPO_DIR/stats.db"     "$OMP_HOME/stats.db"

echo "==> 完成"
echo ""
echo "首次运行 omp 后补装插件："
echo "  omp plugins sync"
