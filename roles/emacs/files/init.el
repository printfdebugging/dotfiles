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
                   "org-roam.el"
                   "org-mode.el"
                   "snippets.el" ;; pending (not working)
                   "user-interface.el"
                   "face-customizations.el"
                   "minibuffer.el"))

(dolist (file my-config-files)
  (let ((file-path (concat my-config-dir file)))
    (when (file-exists-p file-path)
      (load-file file-path))))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("0325a6b5eea7e5febae709dab35ec8648908af12cf2d2b569bedc8da0a3a81c1" default))
 '(package-selected-packages
   '(abc-mode all-the-icons-nerd-fonts cmake-font-lock cmake-project consult-lsp dired-ranger doom-modeline doom-themes embark-consult
              evil-collection evil-commentary evil-leader go-mode indent-bars js2-mode ligature lsp-java lua-mode magit marginalia neotree
              nerd-icons-dired ob-async orderless org-appear org-bullets org-roam org-tidy quelpa quelpa-use-package rainbow-mode
              sudo-edit tree-sitter-langs vertico yaml-mode yasnippet)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
