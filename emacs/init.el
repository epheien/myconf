;; 从零写起的自用 Emacs 配置
;; 仅用于 macOS, 版本 26 以上

;; cl - Common Lisp Extension
;(require 'cl)

;; it's still not 100% equivalent. The case when it's not same is when you quit
;; emacs, and emacs asks if you want to save some files. In that case, pressing
;; Esc doesn't cancel. This is the only case i know it's not same.
(define-key key-translation-map (kbd "ESC") (kbd "C-g"))

;; 避免 emacs-mac 把 alt 改为 super
(setq-default mac-option-modifier 'meta)
;; 避免 emacs-mac 把 super 改为 alt
(setq-default mac-command-modifier 'super)
;; s-x => M-x
(global-set-key (kbd "s-x") 'execute-extended-command)
;; C-x C-x => M-x
(global-set-key "\C-x\C-x" 'execute-extended-command)

;; 禁用响铃
(setq ring-bell-function 'ignore)

;; 显示行号
;(global-linum-mode t)
(setq linum-format "%3d")

;; 去掉边框
(fringe-mode '(4 . 0))

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

;; 菜单栏和工具栏控制
(if (display-graphic-p)
  (progn
    ;; 关闭工具栏，tool-bar-mode 即为一个 Minor Mode
    ;(tool-bar-mode -1)
    ;; 关闭文件滑动控件
    (scroll-bar-mode -1)
  )
  (progn
    ;; 关闭菜单栏
    ;(menu-bar-mode -1)
  )
)

;; 设置图形界面
;; 优先使用字体 SF Mono, 否则 Menlo
(when (window-system)
  ;(set-frame-position (selected-frame) 650 300)
  ;(set-frame-width (selected-frame) 90)
  ;(set-frame-height (selected-frame) 45))
  (add-to-list 'default-frame-alist '(width . 90))
  (add-to-list 'default-frame-alist '(height . 45))
  (add-to-list 'default-frame-alist '(font . "Menlo-12"))
  (add-to-list 'default-frame-alist '(font . "SF Mono-12")))

;; 干掉烦人的 customizing 写入机制
(setq-default custom-file (expand-file-name ".custom.el" user-emacs-directory))
;(when (file-exists-p custom-file)
  ;(load custom-file))

;; 重新加载配置的命令
(defun reload-init.el()
  (interactive)
  (load-file (expand-file-name "init.el" user-emacs-directory)))

;; ==========================================================================
;; 以下的配置全部针对插件
;; ==========================================================================
;; 一些固定的小插件 (undo-tree sdcv posframe ...)
(add-to-list 'load-path (expand-file-name "bundle" user-emacs-directory))

;; ========== evil ==========
;; evil 作为最基础的插件之一, 手动安装并归档! 同时从 melpa 安装是为了看帮助文件!
;; 只需要 vim 风格的键位
(setq evil-want-C-i-jump t)
(setq evil-want-C-u-scroll t)
;; 手动安装 evil:
;;  git clone --depth 1 https://github.com/emacs-evil/evil.git
(add-to-list 'load-path (expand-file-name "evil" user-emacs-directory))
(require 'evil)
(evil-mode 1)

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

;; sdcv 词典
(require 'sdcv)
(setq sdcv-dictionary-data-dir (expand-file-name "~/.stardict/dic"))
(setq sdcv-dictionary-simple-list
      '(
        "朗道英汉字典5.0"
        "朗道汉英字典5.0"
        ))
(setq sdcv-dictionary-complete-list
      '(
        "朗道英汉字典5.0"
        "朗道汉英字典5.0"
        ))

;; ========== elpa ==========
(require 'package)
;; -----
;; bleeding-edge
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  (when no-ssl
    (warn "\
Your version of Emacs does not support SSL connections,
which is unsafe because it allows man-in-the-middle attacks.
There are two things you can do about this warning:
1. Install an Emacs version that does support SSL and be safe.
2. Remove this warning from your init file so you won't see it again."))
  ;; Comment/uncomment these two lines to enable/disable MELPA and MELPA Stable as desired
  (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  ;;(add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
  (when (< emacs-major-version 24)
    ;; For important compatibility libraries like cl-lib
    (add-to-list 'package-archives (cons "gnu" (concat proto "://elpa.gnu.org/packages/")))))
;; stable
;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
;; -----
(package-initialize)

;; 使用的包
(defvar my/packages '(
                      use-package
                      evil ; 安装这个是为了方便看 info
                      which-key
                      doom-theme
                      treemacs
                      ))
(setq package-selected-packages my/packages)

;; This is only needed once, near the top of the file
(eval-when-compile
  ;; Following line is not needed if use-package.el is in ~/.emacs.d
  ;(add-to-list 'load-path (expand-file-name "use-package" user-emacs-directory))
  (require 'use-package))

; which-key
(use-package which-key
  :config
  (which-key-mode)
  )

;; theme
(ignore-errors (load-theme 'doom-one t))

;; company
(use-package company
  :config
  (add-hook 'after-init-hook 'global-company-mode)
  (setq company-minimum-prefix-length 2)
  (setq company-idle-delay 0.1)
  (setq company-dabbrev-minimum-length 2)
  ;(define-key company-active-map (kbd "ESC") 'company-abort)
  (define-key company-active-map (kbd "C-e") 'company-abort)
  (define-key company-active-map (kbd "C-n") 'company-select-next)
  (define-key company-active-map (kbd "C-p") 'company-select-previous)
  (define-key company-active-map (kbd "C-j") 'company-select-next)
  (define-key company-active-map (kbd "C-k") 'company-select-previous))

;; --------------------
;; UNSTABLE
;; --------------------

;; 从官网主页摘录
(use-package treemacs
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs                 (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay      0.5
          treemacs-directory-name-transformer    #'identity
          treemacs-display-in-side-window        t
          treemacs-eldoc-display                 t
          treemacs-file-event-delay              5000
          treemacs-file-extension-regex          treemacs-last-period-regex-value
          treemacs-file-follow-delay             0.2
          treemacs-file-name-transformer         #'identity
          treemacs-follow-after-init             t
          treemacs-git-command-pipe              ""
          treemacs-goto-tag-strategy             'refetch-index
          treemacs-indentation                   2
          treemacs-indentation-string            " "
          treemacs-is-never-other-window         nil
          treemacs-max-git-entries               5000
          treemacs-missing-project-action        'ask
          treemacs-no-png-images                 nil
          treemacs-no-delete-other-windows       t
          treemacs-project-follow-cleanup        nil
          treemacs-persist-file                  (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                      'left
          treemacs-recenter-distance             0.1
          treemacs-recenter-after-file-follow    nil
          treemacs-recenter-after-tag-follow     nil
          treemacs-recenter-after-project-jump   'always
          treemacs-recenter-after-project-expand 'on-distance
          treemacs-show-cursor                   nil
          treemacs-show-hidden-files             t
          treemacs-silent-filewatch              nil
          treemacs-silent-refresh                nil
          treemacs-sorting                       'alphabetic-asc
          treemacs-space-between-root-nodes      t
          treemacs-tag-follow-cleanup            t
          treemacs-tag-follow-delay              1.5
          treemacs-width                         35)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    (treemacs-resize-icons 12)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode t)
    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple))))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

;; TODO
(with-eval-after-load "persp-mode-autoloads"
  (setq wg-morph-on nil) ;; switch off animation
  (setq persp-autokill-buffer-on-remove 'kill-weak)
  (add-hook 'after-init-hook #'(lambda () (persp-mode 1))))

