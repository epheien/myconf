#!/bin/bash
# 验证 setup_linux.sh 的幂等性（在隔离的临时 HOME 中运行，不触碰真实环境）
set -euo pipefail

REPO_DIR=$(cd "$(dirname "$0")" && pwd)

TEST_ROOT=$(mktemp -d)
trap 'rm -rf "$TEST_ROOT"' EXIT
FAKE_HOME=$TEST_ROOT/home
# macOS 上 /var -> /private/var 为符号链接, 与 setup_linux.sh 内 realpath 解析保持一致
FAKE_HOME=$(python3 -c 'import os, sys; print(os.path.realpath(sys.argv[1]))' "$FAKE_HOME")
mkdir -p "$FAKE_HOME"

# 复制仓库中脚本依赖的目录（排除 .git）
mkdir -p "$FAKE_HOME/myconf"
tar -C "$REPO_DIR" --exclude='.git' -cf - vim tmux bash setup_linux.sh \
      | tar -C "$FAKE_HOME/myconf" -xf -

# fake 命令环境: uname 返回 Linux; realpath 用 python3 实现
mkdir -p "$TEST_ROOT/bin"
cat > "$TEST_ROOT/bin/uname" <<'EOF'
#!/bin/bash
if [ "$1" = "-s" ]; then
    echo Linux
    exit 0
fi
exec /usr/bin/uname "$@"
EOF
cat > "$TEST_ROOT/bin/realpath" <<'EOF'
#!/bin/bash
python3 -c 'import os, sys; print(os.path.realpath(sys.argv[1]))' "$1"
EOF
chmod +x "$TEST_ROOT/bin/uname" "$TEST_ROOT/bin/realpath"

export HOME="$FAKE_HOME"
export PATH="$TEST_ROOT/bin:$PATH"

run_setup() {
    (cd "$FAKE_HOME/myconf" && ./setup_linux.sh)
}

fail() {
    echo "FAIL: $1"
    exit 1
}

# --- 用例 1: 首次运行创建全部链接并追加 bashrc ---
run_setup || fail "首次运行退出码非 0"
[ -L "$FAKE_HOME/.vim" ] || fail ".vim 未创建为软链接"
[ "$(readlink "$FAKE_HOME/.vim")" = "myconf/vim" ] || fail ".vim 指向错误: $(readlink "$FAKE_HOME/.vim")"
[ -L "$FAKE_HOME/.config/nvim" ] || fail ".config/nvim 未创建为软链接"
[ "$(readlink "$FAKE_HOME/.config/nvim")" = "../.vim" ] || fail ".config/nvim 指向错误: $(readlink "$FAKE_HOME/.config/nvim")"
[ -L "$FAKE_HOME/.tmux.conf" ] || fail ".tmux.conf 未创建为软链接"
[ -L "$FAKE_HOME/.inputrc" ] || fail ".inputrc 未创建为软链接"
[ -L "$FAKE_HOME/.myshrc" ] || fail ".myshrc 未创建为软链接"
[ "$(grep -c '# load custom config' "$FAKE_HOME/.bashrc")" = "1" ] || fail "bashrc marker 应恰好出现 1 次"
echo "ok: 首次运行"

# --- 用例 2: 二次运行幂等 ---
run_setup || fail "二次运行退出码非 0（幂等性被破坏）"
[ "$(readlink "$FAKE_HOME/.vim")" = "myconf/vim" ] || fail "二次运行后 .vim 指向改变"
[ "$(readlink "$FAKE_HOME/.config/nvim")" = "../.vim" ] || fail "二次运行后 .config/nvim 指向改变"
[ "$(grep -c '# load custom config' "$FAKE_HOME/.bashrc")" = "1" ] || fail "二次运行后 bashrc marker 重复"
echo "ok: 二次运行幂等"

# --- 用例 3: 真实文件占位应跳过并保留原内容 ---
rm -f "$FAKE_HOME/.inputrc"
echo "user data" > "$FAKE_HOME/.inputrc"
run_setup || fail "真实文件冲突场景退出码非 0"
[ -L "$FAKE_HOME/.inputrc" ] && fail "真实文件占位时不应变成软链接"
[ "$(cat "$FAKE_HOME/.inputrc")" = "user data" ] || fail "真实文件内容被破坏"
echo "ok: 真实文件占位被跳过"

# --- 用例 4: 指向别处的软链接应被删除重建修正 ---
rm -f "$FAKE_HOME/.myshrc"
ln -s /somewhere/else "$FAKE_HOME/.myshrc"
run_setup || fail "错误链接场景退出码非 0"
[ "$(readlink "$FAKE_HOME/.myshrc")" = "myconf/bash/myshrc" ] || fail ".myshrc 未被重建修正: $(readlink "$FAKE_HOME/.myshrc")"
echo "ok: 错误软链接被重建修正"

echo "PASS: 全部幂等性测试通过"
