
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
 '(custom-safe-themes
   '("aec7b55f2a13307a55517fdf08438863d694550565dee23181d2ebd973ebd6b8" default))
 '(package-selected-packages
   '(ligature embark nix-mode sideline-flycheck flycheck-posframe lsp-ui-sidelines flycheck-inline org-tidy js2-mode lsp-java lua-mode clang-format org-kanban typescript-mode c-mode ox-rss htmlize simple-httpd org-preview-html go-mode markdown-preview-mode org-download good-scroll webkit-color-picker emojify erc-image iscroll elpher ytdious erc-hl-nicks gptel embark-consult lsp-ui consult-lsp gerrit mu4easy gdb-x yasnippet-snippets page-break-lines treemacs-all-the-icons treemacs-nerd-icons plisp-mode bug-hunter smooth-scrolling org-mode projectile dashboard org-gcal ivy-youtube makefile-executor centaur-tabs git-gutter-fringe git-gutter magit flycheck lsp-treemacs tree-sitter-langs tree-sitter lsp-mode rainbow-mode yaml-mode visual-fill-column which-key vertico sudo-edit org-roam org-bullets org-appear orderless ob-async nerd-icons-dired marginalia harpoon evil-leader evil-commentary evil-collection doom-themes doom-modeline dired-ranger consult all-the-icons-nerd-fonts)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
