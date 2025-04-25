
(use-package yasnippet
  :ensure t
  :config
  (yas-global-mode 1)
  (define-key yas-minor-mode-map (kbd "SPC") yas-maybe-expand)
  (define-key yas-keymap (kbd "TAB") 'yas-next-field-or-maybe-expand))
