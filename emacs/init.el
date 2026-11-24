;;; init.el --- Emacs 配置入口 -*- lexical-binding: t; -*-

;; 插件由 Emacs 自带的 use-package 管理，缺少时从默认的 ELPA 源安装。
(require 'use-package)

(defun reload-init.el ()
  "重新加载入口文件及其列出的所有配置模块。"
  (interactive)
  (load-file (expand-file-name "init.el" user-emacs-directory)))

;; 一些固定的小插件 (undo-tree sdcv posframe ...)
(add-to-list 'load-path (expand-file-name "bundle" user-emacs-directory))

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

;; init.el 可以是软链接，模块位于仓库中实际入口文件旁的 lisp/ 目录。
(let* ((init-file (file-truename (or load-file-name user-init-file)))
       (module-dir (expand-file-name "lisp" (file-name-directory init-file))))
  (dolist (module '("init-editor.el"
                    "init-evil.el"
                    "init-markdown.el"))
    (load (expand-file-name module module-dir) nil 'nomessage)))

;;; init.el ends here
