(use-package nerd-icons-dired)
(use-package dired-ranger)

(defun dw/dired-mode-hook ()
  "clean dired file view"
  (interactive)
  (nerd-icons-dired-mode 1)
  (dired-hide-details-mode 1)
  (hl-line-mode 0))

(use-package dired
  :ensure nil
  :config
    (setq
     dired-listing-switches "-agho --group-directories-first"
     dired-omit-files "^\\.[^.].*"
     dired-omit-verbose nil
     dired-dwim-target 'dired-dwim-target-next
     dired-hide-details-hide-symlink-targets nil
     dired-kill-when-opening-new-dired-buffer t
     delete-by-moving-to-trash t)
  :init
    (add-hook 'dired-mode-hook #'dw/dired-mode-hook)
    (add-hook 'dired-mode-hook 'auto-revert-mode))


;; thanks reddit!!
;; https://www.reddit.com/r/emacs/comments/1ewvz2z/how_to_remove_folder_info_at_the_top_of_direds/
(defun lynn/delete-first-dired-line ()
  (let ((inhibit-read-only t))
    (save-excursion
      (goto-char (point-min))
      (delete-region (point) (line-end-position))
      (delete-char 1))))

(add-hook 'dired-after-readin-hook 'lynn/delete-first-dired-line)
