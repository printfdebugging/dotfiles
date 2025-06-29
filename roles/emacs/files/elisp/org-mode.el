(setq org-src-preserve-indentation t
      org-src-tab-acts-natively nil
      tab-width 2
      indent-tabs-mode nil)

(setq-default indent-tabs-mode nil
              org-list-indent-offset 2)

(use-package org-bullets
  :ensure t
  :hook (org-mode . org-bullets-mode)
  :config
  (setq org-bullets-bullet-list '( "#" "##" "###" "⁖" "⁖" "⁖" "⁖" )))


(use-package org-tidy
  :ensure t
  :hook
  (org-mode . org-tidy-mode))
