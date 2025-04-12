(use-package org-appear
  :ensure t
  :config
  (setq org-hide-emphasis-markers t))

(use-package org-roam
  :ensure t
  :init
  (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory "~/repos/cookbook/wiki")
  (org-roam-completion-everywhere t)
  :config
  (org-roam-db-autosync-mode))

(setq org-roam-capture-templates
      '(("d" "default" plain
         "%?"
         :target (file+head "${slug}.org"
                            "#+TITLE: ${title}\n#+AUTHOR: Sahil Gautam\n#+EMAIL: printfdebugging@gmail.com\n#+EXCLUDE_TAGS: noexport\n#+STATE: draft\n"))))


(defun extract-org-roam-id-at-point ()
  "Extract the ID from the `org-roam` link at point."
  (interactive)
  (let* ((link (thing-at-point 'line t))
         (match (string-match "\\[\\[id:\\([a-zA-Z0-9-]+\\)\\]\\[\\(.*?\\)\\]\\]" link)))
    (if match
        (match-string 1 link)
      (message "No valid org-roam link found at point.")
      nil)))

(defun org-roam-buffer-from-id (id)
  "Return the buffer visiting the Org-roam node with the given ID, creating it if necessary."
  (let ((node (org-roam-node-from-id id)))
    (or (find-buffer-visiting (org-roam-node-file node))
        (find-file-noselect (org-roam-node-file node)))))

(defun goto-org-roam-node-at-point ()
  "Go to the Org-roam node file linked at point."
  (interactive)
  (let ((id (extract-org-roam-id-at-point)))
    (if id
        (let ((buffer (org-roam-buffer-from-id id)))
          (if buffer
              (switch-to-buffer buffer)
            (message "No buffer found for ID: %s" id)))
      (message "FNerd Fontd to extract ID from link at point."))))

(evil-define-key 'normal org-mode-map (kbd "RET") 'goto-org-roam-node-at-point)
