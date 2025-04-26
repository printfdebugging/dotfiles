  ;; most of the faces should be of regular weight
  (dolist (face '(font-lock-doc-face
                  font-lock-string-face
                  font-lock-regexp-face
                  font-lock-type-face
                  font-lock-escape-face
                  font-lock-constant-face
                  font-lock-preprocessor-face
                  font-lock-number-face
                  font-lock-bracket-face
                  font-lock-comment-face
                  button
                  font-lock-keyword-face
                  font-lock-warning-face
                  font-lock-operator-face
                  font-lock-delimiter-face
                  font-lock-doc-markup-face
                  font-lock-punctuation-face
                  font-lock-property-use-face
                  font-lock-variable-use-face
                  font-lock-function-call-face
                  font-lock-function-name-face
                  font-lock-negation-char-face
                  font-lock-property-name-face
                  font-lock-variable-name-face
                  elisp-shorthand-font-lock-face
                  font-lock-misc-punctuation-face
                  font-lock-comment-delimiter-face
                  font-lock-regexp-grouping-backslash
                  font-lock-regexp-grouping-construct))
    (set-face-attribute face nil
                        :weight 'normal
                        :height 135
                        :foreground "#839496"
                        :slant 'normal
                        :underline nil))

  (dolist (face '(font-lock-comment-face
                  font-lock-comment-delimiter-face))
    (set-face-attribute face nil
                        :weight 'normal
                        :height 135
                        :foreground "#5b6268"
                        :slant 'normal
                        :underline nil))

;; emacs-lisp syntax highlighting
(dolist (face '(font-lock-keyword-face
                org-document-info
                dired-directory
                font-lock-builtin-face))
  (set-face-attribute face nil
                      :weight 'normal
                      :slant 'normal
                      :foreground "#839496"
                      :underline nil))

;; editor font
(dolist (face '(default
                fixed-pitch
                variable-pitch))
  (set-face-attribute face nil
                      :family "Iosevka Nerd Font"
                      :height 135
                      :weight 'Regular
                      :foreground "#839496"
                      :background "#001f27"))

;; org mode heading and source block faces
(dolist (face '(org-document-title
                org-level-1
                org-level-2
                org-level-3
                org-level-4
                org-block-begin-line))
  (set-face-attribute face nil
                      :family "Iosevka Nerd Font"
                      :height 135
                      :weight 'Regular
                      :foreground "#839496"
                      :background "#001f27"))

(set-face-attribute 'mode-line nil
                    :background "#002b36")

(set-face-attribute 'mode-line-inactive nil
                    :background "#002b36")
