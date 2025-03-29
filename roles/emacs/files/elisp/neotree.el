(use-package all-the-icons)
(use-package nerd-icons)

(use-package neotree
  :init
  (setq neo-theme                    'nerd-icons
        neo-show-hidden-files         t
        neo-window-width              40
        neo-window-fixed-size         nil
        neo-autorefresh               t
        neo-smart-open                nil
        neo-toggle-window-keep-p      nil
        neo-click-changes-root        nil
        neo-show-slash-for-folder     nil
        neo-mode-line-type           'some-unhandled-value
        neo-cwd-line-style           'button)
  :config
  (doom-modeline-mode 1)
  (define-key neotree-mode-map (kbd "TAB") ;; doesn't work for the time being
              (neotree-make-executor
               :file-fn 'neo-open-file
               :dir-fn  'neo-open-dir)))

;; (defun my-neo-buffer--beginning-of-line ()
;;   "Move cursor to the beginning of the line without adding a newline."
;;   (newline)
;;   (beginning-of-line))

;; (advice-add 'neo-buffer--newline-and-begin :override #'my-neo-buffer--beginning-of-line)
