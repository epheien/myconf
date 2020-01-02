;; 从零写起的自用 Emacs 配置
;; 仅用于 macOS, 版本 26 以上

;; cl - Common Lisp Extension
;(require 'cl)

;; 避免 emacs-mac 把 alt 改为 super
(setq-default mac-option-modifier 'meta)
;; 避免 emacs-mac 把 super 改为 alt
(setq-default mac-command-modifier 'super)
;; s-x -> M-x
(global-set-key (kbd "s-x") 'execute-extended-command)

;; 设置字体
;; TODO: 优先 SF Mono, 否则 Menlo
;(set-default-font "Menlo-12")
(set-frame-font "SF Mono-12")

;; 禁用响铃
(setq ring-bell-function 'ignore)

;; 显示行号
(global-linum-mode t)

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

(when (window-system)
  ;(set-frame-position (selected-frame) 650 300)
  (set-frame-width (selected-frame) 90)
  (set-frame-height (selected-frame) 45))

;; ========== evil ==========
;; 我只需要 vim 风格的键位
(setq evil-want-C-i-jump t)
(setq evil-want-C-u-scroll t)
;; 手动安装 evil:
;;  git clone --depth 1 https://github.com/emacs-evil/evil.git
(add-to-list 'load-path "~/.emacs.d/evil")
(require 'evil)
(evil-mode 1)

;; 定制 evil，主要是键位绑定
(define-key evil-motion-state-map (kbd "SPC") (kbd "3 C-e"))
(define-key evil-motion-state-map "," (kbd "3 C-y"))
(define-key evil-motion-state-map ";" 'evil-ex)
(define-key evil-normal-state-map (kbd "SPC") (kbd "3 C-e"))
(define-key evil-normal-state-map "," (kbd "3 C-y"))
(define-key evil-normal-state-map ";" 'evil-ex)
;; ----- evil

;; 初始化 elpa 的包
(require 'package)
(package-initialize)
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/") t)

;; 使用 gruvbox 主题
(load-theme 'gruvbox t)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages (quote (undo-tree gruvbox-theme))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

