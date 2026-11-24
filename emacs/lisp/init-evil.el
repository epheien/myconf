;;; init-evil.el --- Vim 按键与终端光标 -*- lexical-binding: t; -*-

;; Emacs 31 在兼容 xterm 的终端中同步 Evil 的光标形状。
(setq xterm-update-cursor 'type)

;; evil 作为最基础的插件之一, 手动安装并归档! 同时从 melpa 安装是为了看帮助文件!
;; 只需要 vim 风格的键位
(setq evil-want-C-i-jump t)
(setq evil-want-C-u-scroll t)
(setq evil-move-beyond-eol t)

;; 手动安装 evil:
;; git clone --depth 1 https://github.com/emacs-evil/evil.git ~/.emacs.d/evil
(add-to-list 'load-path (expand-file-name "evil" user-emacs-directory))
(require 'evil)
(evil-mode 1)

;; Emacs 31 不再创建 Evil 1.15 所用的缓冲区列表（Evil #1983）。
(defvar evil-mode-buffers nil)

; 使用 Emacs 内置的撤销与重做
;(setq evil-undo-system 'undo-redo)

;; 针对不同的major-mode做不同处理的C-j键位绑定
(defun my-next-line()
  (interactive)
  (if (and (eq major-mode 'lisp-interaction-mode)
           (eolp)
           (not (equal (current-column) 0)))
    (eval-print-last-sexp)
    (evil-next-line))
  )

;; 定制 evil，主要是键位绑定
;; motion (read-only) mode
(define-key evil-motion-state-map (kbd "SPC") (kbd "3 C-e"))
(define-key evil-motion-state-map "," (kbd "3 C-y"))
(define-key evil-motion-state-map ";" 'evil-ex)
(define-key evil-motion-state-map "\C-f" 'sdcv-search-pointer+)
;; normal mode
(define-key evil-normal-state-map (kbd "SPC") (kbd "3 C-e"))
(define-key evil-normal-state-map "," (kbd "3 C-y"))
(define-key evil-normal-state-map ";" 'evil-ex)
(define-key evil-normal-state-map "\C-f" 'sdcv-search-pointer+)
(define-key evil-normal-state-map "\\=" (lambda()
  (interactive)
  (set-frame-width (selected-frame) (+ (frame-width) 30))))
(define-key evil-normal-state-map "\\-" (lambda()
  (interactive)
  (set-frame-width (selected-frame) (- (frame-width) 30))))
;(define-key evil-normal-state-map "\C-h" 'evil-window-left)
(define-key evil-normal-state-map "\C-j" 'evil-window-down)
(define-key evil-normal-state-map "\C-k" 'evil-window-up)
(define-key evil-normal-state-map "\C-l" 'evil-window-right)
(define-key evil-normal-state-map "\C-s" (lambda() (interactive) (save-buffer)))
(define-key evil-normal-state-map "\C-v" 'yank)
;; insert mode
(define-key evil-insert-state-map "\C-j" 'my-next-line)
(define-key evil-insert-state-map "\C-k" 'evil-previous-line)
(define-key evil-insert-state-map "\C-l" 'forward-char)
(define-key evil-insert-state-map "\C-h" 'backward-char)
(define-key evil-insert-state-map "\C-n" 'next-line)
(define-key evil-insert-state-map "\C-p" 'previous-line)
(define-key evil-insert-state-map "\C-a" 'beginning-of-visual-line)
(define-key evil-insert-state-map "\C-e" 'end-of-visual-line)
(define-key evil-insert-state-map "\C-s" (lambda() (interactive) (evil-normal-state) (save-buffer)))
(define-key evil-insert-state-map "\C-v" 'yank)
;; visual mode
(define-key evil-visual-state-map "\C-c" 'kill-ring-save)
;; ----- evil

;;; init-evil.el ends here
