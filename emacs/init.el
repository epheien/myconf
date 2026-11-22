;;; init.el --- Emacs 编辑配置 -*- lexical-binding: t; -*-

;; 插件由 Emacs 自带的 use-package 管理，缺少时从默认的 ELPA 源安装。
(require 'use-package)

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
