
(use-package go-mode)
(use-package yaml-mode)
(use-package lua-mode)
(use-package lsp-java)
(use-package css-mode)
(use-package js2-mode)
(use-package cmake-mode)
(use-package cmake-project)
(use-package cmake-font-lock)


(use-package lsp-mode
  :hook ((go-mode     . lsp-deferred)
         (c++-mode    . lsp-deferred)
         (java-mode   . lsp-deferred)
         (lua-mode    . lsp-deferred)
         (cmake-mode  . lsp-deferred)
         (yaml-mode   . lsp-deferred)
         (css-mode    . lsp-deferred)
         (xml-mode    . lsp-deferred)
         (sh-mode     . lsp-deferred)
         (c-mode      . lsp-deferred))
  :commands lsp)


(setq lsp-signature-render-documentation nil
      lsp-signature-auto-activate        nil
      lsp-headerline-arrow               "•"
      lsp-headerline-breadcrumb-enable   nil
      lsp-prefer-flymake                 nil
      lsp-enable-symbol-highlighting     nil)
