;;; lisp/evil.el --- Vim 层：evil 及其生态的全部定制 -*- lexical-binding: t; -*-
;;
;; 边界 —— 只放"在 neovim 里也说得通"的东西：vim 的动词、motion、
;;   textobject、evil 生态插件的键位与参数。应用键位（magit/org/workspace/
;;   buffer 这些 leader 之下的宾语）不在这里，将来归各自的 lisp/*.el。
;; 写法 —— 键位一律用 `map!'，不写 `define-key'。Doom 的 leader 挂在 general
;;   的 override map 上，优先级高于 evil-*-state-map，直接 define-key 到
;;   state map 的结果是"绑了也按不出来"。
;; 注释 —— 凡与 Doom/evil 默认不同的条目，写清：
;;   默认: <现值>  →  我: <我的值>    因为: <理由>
;;   依次按 \ h k 查看键绑定，按 \ h v 查看变量文档。
;; 时机 —— `evil-want-*' 必须留在顶层（evil 加载后再设无效）；参数类改动包
;;   `after! evil'；引用 evil-ex-completion-map 这类变量的也必须包。

;;;; 1. 加载前开关

;; 默认: nil（Doom 显式关掉）→ 我: t
;; 因为: 让 C-i 走 evil-jump-forward，与 Vim 一致
(setq evil-want-C-i-jump t)

;; 默认: nil → 我: t   因为: 光标可越行尾，块选截断文本时少一次 v$
(setq evil-move-beyond-eol t)

;; 默认: nil → 我: 'type
;; 因为: Emacs 31 的 TTY 光标形状同步；主入口 emacs-doom 是 TUI
(setq xterm-update-cursor 'type)

;;;; 2. 命令行

;; 默认: `evil-repeat-find-char' → 我: `evil-ex'
;; 因为: `;' 也进 ex，省一次 shift。代价：`;' 不再重复 f/t 跳转。
(map! :n ";" #'evil-ex
      :v ";" #'evil-ex)

;; 默认不区分 Ex 命令补全的类别；标为 command 后，: 和 M-x 共用模糊匹配。
(with-eval-after-load 'evil-ex
  (defun my-evil-ex-command-table (table)
    "给 Ex 命令名补全表添加类别，保留 Evil 的排序规则。"
    (lambda (string pred action)
      (if (eq action 'metadata)
          `(metadata (category . command) ,@(cdr (completion-metadata string table pred)))
        (complete-with-action action table string pred))))
  (advice-add 'evil-ex-completion-table :filter-return #'my-evil-ex-command-table))

;; Doom 在 macOS 上默认等 2 个字符、400 毫秒；Ex 命令短，首字母就提示。
(with-eval-after-load 'corfu
  (defun my-evil-ex-corfu-setup ()
    (when (and corfu-mode (bound-and-true-p evil-ex-original-buffer))
      (require 'corfu-auto)
      (setq-local corfu-auto-prefix 1
                  corfu-auto-delay 0.05)))
  (add-hook 'corfu-mode-hook #'my-evil-ex-corfu-setup))

;;;; 3. 窗口与保存

;; 默认: Doom 用 `C-w h/j/k/l' → 我: 直接 C-h/j/k/l（两者并存）
;(map! :n "C-h" #'evil-window-left)
(map! :n "C-j" #'evil-window-down)
(map! :n "C-k" #'evil-window-up)
;(map! :n "C-l" #'evil-window-right)

;; 默认: `C-x C-s' → 我: `C-s'
(map! :n "C-s" #'save-buffer)

;;;; 4. insert 区（readline 风格；C-n/C-p 留给 corfu）

(defun my-next-line ()
  "lisp-interaction-mode 里行尾的 C-j 直接求值，其余情况 down-line。"
  (interactive)
  (if (and (derived-mode-p 'lisp-interaction-mode)
           (eolp)
           (/= (current-column) 0))
      (eval-print-last-sexp)
    (next-line)))

(map! :i "C-j" #'my-next-line
      ;; 默认: `C-k' = evil-insert-digraph → 我: 上一行（二合字母极少用）
      :i "C-k" #'previous-line
      :i "C-a" #'beginning-of-visual-line
      :i "C-e" #'end-of-visual-line
      ;; 默认: `C-h' = delete-backward-char → 我: backward-char（删除仍用 Backspace）
      :i "C-h" #'backward-char
      :i "C-l" #'forward-char
      ;; 默认: 未绑 → 我: 存盘并回 normal
      :i "C-s" (cmd! (evil-normal-state) (save-buffer)))

;;;; 5. visual 区

;; 默认: 未绑 → 我: `C-c' 复制（`y' 保持原样）
(map! :v "C-c" #'kill-ring-save)

;;;; 6. ex 命令行 + vertico
;; 作用：`:' 之后按 TAB，用 vertico 在 minibuffer 浮窗里补全 ex 命令与参数，
;;   回车直接执行原文（含缩写、行号、替换表达式）。
;; Doom 只在 minibuffer maps 补了几个键，没有这层浮窗集成，故自备。

;(after! evil
;  (defun my-evil-ex-vertico-table ()
;    "从 Evil 取得光标处的命令或参数补全表，保留其前面的 Ex 命令行。"
;    (pcase-let ((`(,beg ,end ,table . ,props)
;                 (and (eobp) (ignore-errors (evil-ex-completion-at-point)))))
;      (setq-local minibuffer-completion-predicate (plist-get props :predicate)
;                  minibuffer-completion-table
;                  (when (and beg (= end (point)))
;                    (completion-table-subvert
;                     table (buffer-substring-no-properties (minibuffer-prompt-end) beg) "")))))
;
;  (defun my-evil-ex-vertico-insert ()
;    "补全光标所在的命令或参数。"
;    (interactive)
;    (if (and (eobp) minibuffer-completion-table)
;        (progn (vertico--update) (vertico-insert))
;      (completion-at-point)))
;
;  (defvar-keymap my-evil-ex-vertico-map
;    :parent evil-ex-completion-map
;    "TAB" #'my-evil-ex-vertico-insert "<tab>" #'my-evil-ex-vertico-insert
;    "RET" #'vertico-exit "<return>" #'vertico-exit
;    "<down>" #'vertico-next "<up>" #'vertico-previous
;    "C-n" #'vertico-next "C-p" #'vertico-previous
;    "M-n" #'next-history-element "M-p" #'previous-history-element)
;
;  (defun my-evil-ex-vertico-setup ()
;    "为 Evil Ex 命令行启用 Vertico 浮窗。"
;    (when (and (bound-and-true-p vertico-mode)
;               (eq (current-local-map) evil-ex-completion-map))
;      ;; Evil 在空输入时会从历史里执行上一条命令，先清掉它预填的灰色文本。
;      (when (memq #'evil-ex-remove-default pre-command-hook)
;        (delete-minibuffer-contents))
;      ;; 直接回车执行原文，包括缩写、行号和替换表达式。
;      (setq-local vertico-preselect 'prompt)
;      (my-evil-ex-vertico-table)
;      (vertico--setup)
;      (use-local-map my-evil-ex-vertico-map)
;      (add-hook 'post-command-hook #'my-evil-ex-vertico-table -10 t)))
;
;  (add-hook 'minibuffer-setup-hook #'my-evil-ex-vertico-setup 90))

;;;; 7. 滚动
;; 可选：用 SPC 和逗号向下、向上滚动三行。
(map! :nvm "SPC" (cmd! (evil-scroll-line-down 3))
      :nvm ","   (cmd! (evil-scroll-line-up 3)))
