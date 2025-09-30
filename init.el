;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; do't overwrite init.el ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(make-temp-file "/tmp/emacs-custom")
(setq custom-file "/tmp/emacs-custom")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; add package repositories ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq
 package-archives '(("GNU ELPA"     . "https://elpa.gnu.org/packages/")
		    ("MELPA"        . "https://melpa.org/packages/")
		    ("ORG"          . "https://orgmode.org/elpa/")
		    ("MELPA Stable" . "https://stable.melpa.org/packages/")
		    ("nongnu"       . "https://elpa.nongnu.org/nongnu/"))
 package-archive-priorities '(("GNU ELPA"     . 20)
			      ("MELPA"        . 15)
			      ("ORG"          . 10)
			      ("MELPA Stable" . 5)
			      ("nongnu"       . 0)))
(package-initialize)


;;;;;;;;;;;;;;;;;;;
;; minimalist ui ;;
;;;;;;;;;;;;;;;;;;;
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(fringe-mode 0)
(defun display-startup-echo-area-message () (message ""))
(setq inhibit-startup-screen t
      inhibit-splash-screen t
      inhibit-startup-message t
      initial-scratch-message "")



;;;;;;;;;;;;;;;;;;;;;;;;;
;; face customizations ;;
;;;;;;;;;;;;;;;;;;;;;;;;;
(set-face-attribute 'default nil :family "JetBrainsMono Nerd Font" :height 210)
(set-face-attribute 'fixed-pitch nil :family "JetBrainsMono Nerd Font" :height 210)
(set-face-attribute 'variable-pitch nil :family "JetBrainsMono Nerd Font" :height 210)



;;;;;;;;;;;;;;;
;; evil mode ;;
;;;;;;;;;;;;;;;
(use-package evil
  :ensure t
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init))

(use-package evil-leader
  :ensure t
  :config
  (evil-leader/set-leader "<SPC>")
  (global-evil-leader-mode)
  (evil-leader/set-key
   "sh" 'split-window-vertically
   "ls" 'consult-buffer
   "sv" 'split-window-horizontally
   "." 'find-file
   "b" 'switch-to-buffer
   "k" 'kill-buffer))


;;;;;;;;;;;;;;;;;
;; keybindings ;;
;;;;;;;;;;;;;;;;;
(global-unset-key   (kbd "C-t"))
(global-set-key (kbd "C-c t") 'tab-new)
(global-set-key (kbd "C-c x") 'tab-close)


;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; theming and interface ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package doom-themes
  :ensure t
  :init
  (setq doom-themes-enable-bold t)
  (setq	doom-themes-enable-italic t)
  :config
  (load-theme 'doom-one t))

(use-package doom-modeline
  :ensure t
  :init
  (setq doom-modeline-height 44)
  :hook (after-init . doom-modeline-mode))

;;;;;;;;;;;;;
;; vertico ;;
;;;;;;;;;;;;;
(use-package vertico
  :ensure t
  :custom
  (vertico-scroll-margin 0) ;; Different scroll margin
  (vertico-count 6) ;; Show more candidates
  (vertico-resize nil) ;; Grow and shrink the Vertico minibuffer
  (vertico-cycle t) ;; Enable cycling for `vertico-next/previous'
  :init
  (vertico-mode))

(use-package marginalia
  :after vertico
  :ensure t
  :custom
  (marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))
  :init
  (marginalia-mode))

;; persist history. vertico sorts by history position.
(use-package savehist
  :ensure t
  :init
  (savehist-mode))

;; emacs minibuffer configurations.
(use-package emacs
  :ensure t
  :custom
  (context-menu-mode t)
  (enable-recursive-minibuffers t)
  (read-extended-command-predicate #'command-completion-default-include-p)
  (minibuffer-prompt-properties '(read-only t cursor-intangible t face minibuffer-prompt)))

;; Optionally use the `orderless' completion style.
(use-package orderless
  :ensure t
  :custom
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (orderless-style-dispatchers '(+orderless-consult-dispatch orderless-affix-dispatch))
  ;; (orderless-component-separator #'orderless-escapable-split-on-space)
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-category-defaults nil) ;; Disable defaults, use our settings
  (completion-pcm-leading-wildcard t)) ;; Emacs 31: partial-completion behaves like substring

(setq window-resize-pixelwise t
      frame-resize-pixelwise t)

;;;;;;;;;;;;;;;;;;
;; vim like tab ;;
;;;;;;;;;;;;;;;;;;
(use-package vim-tab-bar
  :ensure t
  :config
  (vim-tab-bar-mode 1))

(use-package consult
  :ensure t)
