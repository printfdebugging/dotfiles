
;; (defun efs/split-vertically()
;;   (interactive)
;;   (select-window (split-window-vertically)))

;; (defun efs/split-horizontally()
;;   (interactive)
;;   (select-window (split-window-horizontally)))

(defun efs/toggle-vterm ()
  "toggle the visibility of the *vterm* buffer."
  (interactive)
  (if (get-buffer-window "*terminal*")
      ;; If *vterm* buffer is already visible, delete its window
      (delete-window (get-buffer-window "*terminal*"))
    ;; Otherwise, show *vterm* buffer in a new window
    (select-window (split-window-vertically) )
    (term "/usr/bin/zsh")
    (text-scale-set 0)))

(require 'bind-key)
(bind-key* "C-z" 'efs/toggle-vterm)

(use-package evil-leader
  :ensure t
  :config
  (global-evil-leader-mode)
  (evil-leader/set-leader "<SPC>")
  (evil-leader/set-key
    "w" 'save-buffer
    "W" 'evil-write-all
    "." 'find-file
    "q" 'evil-quit
    "ot" 'org-roam-buffer-toggle
    "oo" 'org-open-at-point-global
    "x" 'org-babel-execute-src-block
    "t" 'execute-current-file-program
    "rr" 'org-babel-remove-result
    "bk" 'kill-buffer
    "e" 'neotree-toggle

    ;; Git-Gutter keybindings
    "gn" 'git-gutter:next-hunk
    "gp" 'git-gutter:previous-hunk
    "gx" 'git-gutter:revert-hunk
    "gt" 'git-gutter:popup-diff
    "gh" 'magit

    "gr" 'lsp-find-references

    "ff" 'consult-fd
    "fs" 'consult-ripgrep
    "fb" 'consult-lsp-file-symbols
    "rn" 'lsp-rename

    "ls" 'consult-buffer
    "mf" 'make-frame
    "ub" 'eww-back-url
    "un" 'eww-next-url
    "be" 'sudo-edit
    "of" 'org-roam-node-find
    "oi" 'org-roam-node-insert
    "or" 'org-babel-remove-result-one-or-many
    ;; "sh" (lambda () (interactive) (efs/split-vertically))
    ;; "sv" (lambda () (interactive) (efs/split-horizontally))
    ;; "z"  (lambda () (interactive) (efs/toggle-vterm))

    ;; harpoon.el keybindings
    "1"  'harpoon-go-to-1
    "2"  'harpoon-go-to-2
    "3"  'harpoon-go-to-3
    "4"  'harpoon-go-to-4
    "5"  'harpoon-go-to-5
    "6"  'harpoon-go-to-6
    "mm" 'harpoon-add-file
    "me" 'harpoon-delete-item
    ))
;; harpoon.el keybindings
(evil-define-key 'normal global-map (kbd "C-e") 'harpoon-toggle-quick-menu)
(evil-define-key 'normal 'global (kbd "gq") 'set-justification-full)
(evil-define-key 'normal 'global (kbd "z") 'efs/toggle-vterm)

(global-set-key (kbd "<escape>") 'keyboard-escape-quit)
(add-hook 'org-mode-hook (lambda ()
                           (evil-define-key 'normal org-mode-map (kbd "TAB") 'org-cycle)))
(setq-default tab-width 2)

;; I will try the C-w hjkl for sometime
;; (evil-define-key 'normal global-map (kbd "C-h") 'evil-window-left)
;; (evil-define-key 'normal global-map (kbd "C-j") 'evil-window-down)
;; (evil-define-key 'normal global-map (kbd "C-k") 'evil-window-up)
;; (evil-define-key 'normal global-map (kbd "C-l") 'evil-window-right)

;; keep the cursor as a block in evil insert mode
(setq evil-insert-state-cursor 'box)
;; reload function
(defun revert-buffer-no-confirm ()
  "Revert buffer without confirmation."
  (interactive)
  (revert-buffer :ignore-auto :noconfirm))



(use-package sudo-edit
  :ensure t)
(evil-define-key 'normal global-map (kbd "C-b e") 'sudo-edit)
(evil-define-key 'normal global-map (kbd "C-b k") 'kill-buffer)

(use-package which-key
  :ensure t
  :init
  (which-key-mode))
