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

;; Evil 的 u 和 C-r 使用 bundle 中的 undo-tree，撤销历史只保存在内存中。
(require 'undo-tree)
(setopt evil-undo-system 'undo-tree
        undo-tree-auto-save-history nil)
(global-undo-tree-mode 1)
(evil-mode 1)

(defun my-evil-ex-vertico-table ()
  "从 Evil 取得光标处的命令或参数补全，保留其前面的 Ex 命令行。"
  (pcase-let ((`(,beg ,end ,table . ,props)
               (and (eobp) (ignore-errors (evil-ex-completion-at-point)))))
    (setq-local minibuffer-completion-predicate (plist-get props :predicate)
                minibuffer-completion-table
                (when (and beg (= end (point)))
                  (completion-table-subvert
                   table (buffer-substring-no-properties (minibuffer-prompt-end) beg) "")))))

(defun my-evil-ex-vertico-insert ()
  "补全光标所在的命令或参数。"
  (interactive)
  (if (and (eobp) minibuffer-completion-table)
      (progn (vertico--update) (vertico-insert))
    (completion-at-point)))

(defvar-keymap my-evil-ex-vertico-map
  :parent evil-ex-completion-map
  "TAB" #'my-evil-ex-vertico-insert "<tab>" #'my-evil-ex-vertico-insert
  "RET" #'vertico-exit "<return>" #'vertico-exit
  "<down>" #'vertico-next "<up>" #'vertico-previous
  "C-n" #'vertico-next "C-p" #'vertico-previous
  "M-n" #'next-history-element "M-p" #'previous-history-element)

(defun my-evil-ex-vertico-setup ()
  "为 Evil Ex 命令行启用 Vertico 浮窗。"
  (when (and (bound-and-true-p vertico-mode)
             (eq (current-local-map) evil-ex-completion-map))
    ;; Evil 在空输入时会从历史中执行上条命令，先清除其灰色预填文本。
    (when (memq #'evil-ex-remove-default pre-command-hook)
      (delete-minibuffer-contents))
    ;; 直接回车执行原文，包括缩写、行号和替换表达式。
    (setq-local vertico-preselect 'prompt)
    (my-evil-ex-vertico-table)
    (vertico--setup)
    (use-local-map my-evil-ex-vertico-map)
    (add-hook 'post-command-hook #'my-evil-ex-vertico-table -10 t)))

(add-hook 'minibuffer-setup-hook #'my-evil-ex-vertico-setup 90)

;; Emacs 31 不再创建 Evil 1.15 所用的缓冲区列表（Evil #1983）。
(defvar evil-mode-buffers nil)

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
