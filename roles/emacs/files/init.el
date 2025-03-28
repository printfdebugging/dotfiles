(setq
 my-config-dir (expand-file-name "~/.config/emacs/elisp/")
 my-config-files '("use-package.el"
                   "doom-modeline.el"
                   "evil-mode.el"
                   "keymaps.el"
                   "doom-theme.el"
                   "dired-mode.el"
                   "indent-bars.el"
                   "irc.el" ;; pending
                   "ligatures.el"
                   "lsp-mode.el"
                   "mail.el" ;; pending
                   "programming.el"
                   "neotree.el" ;; pending (remove the path from the top)
                   "org-babel.el"
                   "org-mode.el"
                   "snippets.el" ;; pending (not working)
                   "user-interface.el"
                   "face-customizations.el"
                   "minibuffer.el"))

(dolist (file my-config-files)
  (let ((file-path (concat my-config-dir file)))
    (when (file-exists-p file-path)
      (load-file file-path))))
