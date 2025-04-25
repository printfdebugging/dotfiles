
;; don't ask before executing source block
(setq org-confirm-babel-evaluate nil)
(org-babel-do-load-languages
    'org-babel-load-languages
    '((emacs-lisp . t)
      (python     . t)
      (shell      . t)))

(use-package ob-async
  :ensure t)
