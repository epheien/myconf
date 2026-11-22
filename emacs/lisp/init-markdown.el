;;; init-markdown.el --- Markdown 编辑与预览 -*- lexical-binding: t; -*-

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

;;; init-markdown.el ends here
