;;; init-evil.el --- Vim 按键与终端光标 -*- lexical-binding: t; -*-

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

;;; init-evil.el ends here
