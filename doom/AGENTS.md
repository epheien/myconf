# AGENTS.md

本目录是 Doom Emacs 的**个人配置目录**（`DOOMDIR`），只有配置，不含框架源码。框架装在
`~/.config/emacs-doom/`（`EMACSDIR`）。

源文件属于 `~/myconf` 仓库，`~/.config/doom` 只是指向它的软链（`-> ../myconf/doom`）。因此：

- `~/.config/doom/*.el` 和 `~/myconf/doom/*.el` 是同一批文件，两条路径都能编辑。
- 提交在 `~/myconf` 里做（`git add doom && git commit`），不要在本目录另建仓库。
- **不要把这个软链换成真目录**：`DOOMDIR` 的取值仍是 `~/.config/doom`，那里一旦变成独立的
  真目录，Doom 就会读写另一份配置，形成静默分叉的两套配置。

下文路径一律写成 `~/...`、`$DOOMDIR`、`$EMACSDIR` 的形式。脚本和文档里请用这些变量或
`~`，不要硬编码某台主机的绝对路径（`/Users/xxx`、`/home/xxx`、`/Applications/...`）。
Emacs 版本也因主机而异，文中的 `31.1` 只是本机当前值。

## 命令

| 命令 | 实际行为 |
| --- | --- |
| `emacs-doom` | 终端（TUI）Emacs。设 `DOOMDIR=~/.config/doom`、`EMACS_SERVER_NAME=doom`，再执行 `emacs --init-directory="$HOME/.config/emacs-doom"`。其中 `~/.local/bin/emacs` 是 `-nw` 封装：macOS 上转发给 Emacs.app 内的二进制，Linux 上一般就是发行版包 |
| `doom <cmd>` | 管理 CLI。设 `DOOMDIR` 与 `EMACS`（GUI 二进制：macOS 为 `Emacs.app/Contents/MacOS/Emacs`，Linux 通常直接用 `$PATH` 上的 `emacs`），再执行 `$EMACSDIR/bin/doom` |
| `doom sync` | 装缺失插件、重生成 autoloads 与 `.local/etc/@/init.<Emacs 版本>.el`。改 `init.el` / `packages.el` 后必须执行 |
| `doom doctor` | 环境诊断 |
| `doom info` | 输出配置详情（报错求助用） |

CLI 日志在 `$EMACSDIR/.local/state/logs/cli.doom.*.log`，`doom sync` 失败时先看最新的那个。

注意 `doom` 用 GUI 二进制，`emacs-doom` 用 `-nw` 封装，两者行为不同（GUI frame vs 终端）。

## 可编辑的文件

| 文件 | 内容 | 改完要做 |
| --- | --- | --- |
| `$DOOMDIR/init.el` | 启用哪些 Doom 模块（`doom!` 块） | `doom sync` |
| `$DOOMDIR/config.el` | 日常设置：`doom-theme`=`doom-one`、`display-line-numbers-type`、`org-directory`、`server-name`=`doom` | 重启，或 `M-x doom/reload` |
| `$DOOMDIR/packages.el` | 额外插件与版本固定（`package!`） | `doom sync` |
| `$DOOMDIR/custom.el` | Customize 界面写入的设置 | 目前不存在；一旦出现即视为生成文件 |

## 不要编辑

`$EMACSDIR` 下的任何内容（`$DOOMDIR` 除外），特别是：

- `lisp/`、`modules/`、`sources/doom+/modules/` —— Doom 核心与模块实现
- `early-init.el`、`bin/`、`.local/etc/@/init.<Emacs 版本>.el` —— 框架入口与生成文件
- `.local/straight/repos/`、`.local/straight/build-<Emacs 版本>/` —— 插件源码与编译产物
- `.local/cache/` —— 运行缓存（`eln/`、savehist、autosave、projectile 项目列表）

要改行为就改 `init.el` / `config.el`；框架目录会被 `doom upgrade` 整体覆盖。

## 路径陷阱

- Doom 里 `user-emacs-directory` 等于 `$EMACSDIR/.local/cache/`。**它不是配置目录**，
  别拿它拼配置或插件路径。
- 个人配置目录用 `doom-user-dir`（= `$DOOMDIR` = `~/.config/doom`，经软链到达 `~/myconf/doom`）。
- 框架目录用 `doom-emacs-dir`（= `$EMACSDIR`）。
- `org-directory` 是 `~/org/`，**该目录目前还不存在**，写文件前先创建。

## 编辑规范

- 包相关设置包进 `with-eval-after-load`，否则会被 Doom 默认值覆盖。仅三类可直接写在顶层：
  文件/目录变量（如 `org-directory`）、文档明确要求加载前设置的变量、`doom-` 与 `+` 开头的变量。
- 用 Doom 提供的 `load!`、`add-load-path!`、`map!`，不要手写 `add-to-list 'load-path` 或 `define-key`。
- 保留 `config.el` 首行 `;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-`，它提供 `lexical-binding`。
- 模板注释是用户的学习材料：只做增量插入，别重排、别删除、别整体格式化。
- 不要把 Customize 生成的 `(custom-set-variables ...)` 混进 `config.el`。

## 改完怎么验证

```bash
# 1. 括号/编码快检，不启动 Doom
cd ~/.config/doom && emacs -Q --batch --eval \
  '(dolist (f (list "init.el" "config.el" "packages.el")) (with-temp-buffer (insert-file-contents f) (check-parens)))'
```

2. 改 `config.el`：重启 `emacs-doom`，或 `M-x doom/reload`。
3. 改 `init.el` / `packages.el`：`doom sync`，再 `tail -n 30` 最新日志，确认无 `Error` / `Warning`。
4. 启动后看 `*Messages*`；要报错栈就 `M-x toggle-debug-on-error` 后复现。
5. 环境类疑难用 `doom doctor`。
