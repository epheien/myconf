;;; init.el --- Emacs 编辑配置 -*- lexical-binding: t; -*-

;; it's still not 100% equivalent. The case when it's not same is when you quit
;; emacs, and emacs asks if you want to save some files. In that case, pressing
;; Esc doesn't cancel. This is the only case i know it's not same.
(define-key key-translation-map (kbd "ESC") (kbd "C-g"))

;; 避免 emacs-mac 把 alt 改为 super
(setq-default mac-option-modifier 'meta)
;; 避免 emacs-mac 把 super 改为 alt
(setq-default mac-command-modifier 'super)
;; S-x(⌘x) => M-x
(global-set-key (kbd "s-x") 'execute-extended-command)
;; C-x C-x => M-x
(global-set-key "\C-x\C-x" 'execute-extended-command)

;; 禁用响铃
(setq ring-bell-function 'ignore)

;; 显示行号：用内置的 display-line-numbers（C 实现，linum-mode 已在 Emacs 31 移除）。
;; 想要 Vim 的 relativenumber 混合效果，把 t 改成 'relative。
(setopt display-line-numbers-type t
        display-line-numbers-width-start t)
(global-display-line-numbers-mode 1)

;; 隐藏图形界面编辑区两侧的边栏。
(fringe-mode 0)

;; 回绕标识, 太丑了, 关掉!
(global-visual-line-mode nil)

;; 关闭启动帮助画面
;(setq inhibit-splash-screen t)

;; info 帮助文档
;;  1. 复制 xxx.info 到 info 目录
;;  2. install-info --info-dir=dir-path dir-path/file
(add-to-list 'Info-default-directory-list "~/.emacs.d/info")

;; 关闭备份机制
(setq make-backup-files nil)

;; 菜单栏和工具栏控制
(if (display-graphic-p)
  (progn
    ;; 关闭工具栏，tool-bar-mode 即为一个 Minor Mode
    (tool-bar-mode -1)
    ;; 关闭文件滑动控件
    (scroll-bar-mode -1)
  )
  (progn
    ;; 关闭菜单栏
    ;(menu-bar-mode -1)
  )
)

;; 重新加载配置的命令
(defun reload-init.el()
  (interactive)
  (load-file (expand-file-name "init.el" user-emacs-directory)))

;; 插件由 Emacs 自带的 use-package 管理，缺少时从默认的 ELPA 源安装。
(require 'use-package)

;; Emacs 31 在兼容 xterm 的终端中同步 Evil 的光标形状。
(setq xterm-update-cursor 'type)

;; Vim 操作：启动时启用，使用 Emacs 内置的撤销与重做。
(use-package evil
  :ensure t
  :init
  ;; Emacs 31 不再创建 Evil 1.15 所用的缓冲区列表（Evil #1983）。
  (defvar evil-mode-buffers nil)
  (setq evil-undo-system 'undo-redo
        evil-want-C-u-scroll t)
  :config
  (evil-mode 1))

;; 光标贴到窗口边缘时只滚动一行，而不是整窗重画（Vim 行为）。
(setopt scroll-conservatively 101)

;; Neovim 风格的纵向滚动：滚轮每格 3 行，Shift + 滚轮翻页。
(xterm-mouse-mode 1)
(setopt mouse-wheel-scroll-amount
        '(3 ((shift) . nil)
            ((meta) . nil)
            ((control) . text-scale)
            ((control meta) . global-text-scale))
        mouse-wheel-progressive-speed nil
        mouse-wheel-follow-mouse t)

;; Markdown：直接在编辑区显示排版，按 C-c C-x C-m 可切换标记。
(use-package markdown-mode
  :ensure t
  :defer t
  :custom
  (markdown-hide-markup t)
  (markdown-fontify-code-blocks-natively t)
  :config
  ;; 从 Finder 启动时，PATH 可能不包含安装 cmark 的 Python 虚拟环境。
  (let ((exec-path (append exec-path (list (expand-file-name "~/.venv/bin")))))
    (when-let* ((cmark (executable-find "cmark")))
      (setq markdown-command (list cmark)))))

;;; init.el ends here
