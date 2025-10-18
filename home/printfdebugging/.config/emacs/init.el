(make-temp-file "/tmp/emacs-custom")
(setq custom-file "/tmp/emacs-custom")

(package-initialize)
(org-babel-load-file "~/.config/emacs/config.org")
