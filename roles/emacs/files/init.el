
;; Configure package.el to include MELPA.
(require 'package)
(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/") t)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)
(package-initialize)

(when (not (package-installed-p 'use-package))
  (package-refresh-contents)
  (package-install 'use-package))
(setq use-package-always-ensure t)

(org-babel-load-file "~/.config/emacs/config.org")
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(modern-cpp-font-lock cmake-font-lock cmake-project cmake-mode yasnippet yaml-mode which-key visual-fill-column vertico tree-sitter-langs sudo-edit rainbow-mode org-tidy org-roam org-download org-bullets org-appear orderless ob-async nix-mode nerd-icons-dired marginalia magit lua-mode lsp-java ligature js2-mode harpoon good-scroll go-mode git-gutter-fringe evil-leader evil-commentary evil-collection embark-consult doom-themes doom-modeline dired-ranger consult-lsp all-the-icons-nerd-fonts)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
