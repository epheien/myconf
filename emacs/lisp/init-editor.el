;;; init-editor.el --- 通用编辑、显示和滚动设置 -*- lexical-binding: t; -*-

(use-package gruvbox-theme
  :ensure t
  :no-require t
  :config
  (load-theme 'gruvbox-dark-medium t))

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

;; GUI 窗口初始大小
(add-to-list 'default-frame-alist '(width . 120))
(add-to-list 'default-frame-alist '(height . 40))

;; 回绕标识, 太丑了, 关掉!
(global-visual-line-mode nil)

;; 关闭启动帮助画面
(setq inhibit-splash-screen t)

;; info 帮助文档
;;  1. 复制 xxx.info 到 info 目录
;;  2. install-info --info-dir=dir-path dir-path/file
(add-to-list 'Info-default-directory-list "~/.emacs.d/info")

;; 关闭备份机制
(setq make-backup-files nil)

;; 图形界面隐藏工具栏和滚动条。
(when (display-graphic-p)
  (tool-bar-mode -1)
  (scroll-bar-mode -1))

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

;;; init-editor.el ends here
