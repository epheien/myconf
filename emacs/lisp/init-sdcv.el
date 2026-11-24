;;; init-sdcv.el --- sdcv 词典配置 -*- lexical-binding: t; -*-
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
