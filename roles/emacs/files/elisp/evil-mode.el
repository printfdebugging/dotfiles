(defun my-tab-behavior ()
  "insert a tab or complete at point based on whether the cursor is placed after a space or a character."
  (interactive)
  (let ((col (current-column)))
    (if (or (= col 0)
            (member (char-before) '(?\s ?\t)))
        (insert-tab)
      (completion-at-point))))


(setq-default evil-want-keybinding nil)

(use-package evil
  :config
    (evil-set-undo-system 'undo-redo)
  :init
    (evil-mode 1)) 

(use-package evil-collection
  :after evil
  :config
    (evil-collection-init))

(use-package evil-commentary
  :config
    (evil-commentary-mode))

(define-key evil-insert-state-map (kbd "TAB") 'my-tab-behavior)
(define-key evil-visual-state-map "gc" 'evil-commentary)
