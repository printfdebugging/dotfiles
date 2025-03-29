(defun display-startup-echo-area-message ()
  "don't show the initial help message in minibuffer area"
  (message ""))

(setq scroll-conservatively         1000
      scroll-margin                 0
      initial-scratch-message       ""
      inhibit-startup-message       t
      standard-indent               2
      server-client-instructions    nil
      ring-bell-function           'ignore
      truncate-lines                t
      make-backup-files             nil
      minibuffer-eldoc-mode         nil
      hscroll-step                  1
      use-dialog-box                nil
      frame-resize-pixelwise        t
      inhibit-startup-message       t)

(setq-default fill-column              138
              truncate-lines           t)

(tool-bar-mode    -1)
(menu-bar-mode    -1)
(scroll-bar-mode  -1)
(fringe-mode       0)

(display-line-numbers-mode 0)


(use-package all-the-icons-nerd-fonts
  :ensure t
  :config
  (unless (directory-files (expand-file-name "elpa" user-emacs-directory) t "^all-the-icons-nerd-fonts")
    (nerd-icons-install-fonts t)))
(setq org-startup-with-inline-images t)


;; refresh on external change
(global-auto-revert-mode)
