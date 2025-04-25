(defun my-customize-faces ()
  ;; most of the faces should be of regular weight
  (dolist (face '(tree-sitter-hl-face:variable
                  tree-sitter-hl-face:punctuation.delimiter
                  tree-sitter-hl-face:doc
                  tree-sitter-hl-face:tag
                  tree-sitter-hl-face:type
                  tree-sitter-hl-face:label
                  tree-sitter-hl-face:escape
                  tree-sitter-hl-face:method
                  tree-sitter-hl-face:number
                  tree-sitter-hl-face:string
                  tree-sitter-hl-face:comment
                  tree-sitter-hl-face:keyword
                  tree-sitter-hl-face:constant
                  tree-sitter-hl-face:embedded
                  tree-sitter-hl-face:function
                  tree-sitter-hl-face:operator
                  tree-sitter-hl-face:property
                  tree-sitter-hl-face:attribute
                  tree-sitter-hl-face:type.super
                  tree-sitter-hl-face:constructor
                  tree-sitter-hl-face:method.call
                  tree-sitter-hl-face:punctuation
                  tree-sitter-hl-face:type.builtin
                  tree-sitter-hl-face:function.call
                  tree-sitter-hl-face:type.argument
                  tree-sitter-hl-face:function.macro
                  tree-sitter-hl-face:string.special
                  tree-sitter-hl-face:type.parameter
                  tree-sitter-hl-face:constant.builtin
                  tree-sitter-hl-face:function.builtin
                  tree-sitter-hl-face:function.special
                  tree-sitter-hl-face:variable.builtin
                  tree-sitter-hl-face:variable.special
                  tree-sitter-hl-face:variable.parameter
                  tree-sitter-hl-face:property.definition
                  tree-sitter-hl-face:punctuation.bracket
                  tree-sitter-hl-face:punctuation.special
                  font-lock-doc-face
                  font-lock-string-face
                  font-lock-regexp-face
                  font-lock-type-face
                  font-lock-escape-face
                  font-lock-constant-face
                  font-lock-preprocessor-face
                  font-lock-number-face
                  font-lock-bracket-face
                  font-lock-comment-face
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
                        :height 160
                        :slant 'normal
                        :underline nil))

  ;; some faces should be bold
  (dolist (face '(tree-sitter-hl-face:method
                  tree-sitter-hl-face:constant
                  tree-sitter-hl-face:embedded
                  tree-sitter-hl-face:function
                  tree-sitter-hl-face:property
                  tree-sitter-hl-face:type.super
                  tree-sitter-hl-face:constructor
                  tree-sitter-hl-face:method.call
                  tree-sitter-hl-face:function.call
                  tree-sitter-hl-face:function.macro
                  tree-sitter-hl-face:constant.builtin
                  tree-sitter-hl-face:function.builtin
                  tree-sitter-hl-face:function.special
                  tree-sitter-hl-face:variable.builtin))
    (set-face-attribute face nil
                        :weight 'bold
                        :slant 'normal
                        :height 160
                        :underline nil))

  (dolist (face '(tree-sitter-hl-face:type.builtin
                  tree-sitter-hl-face:function.builtin
                  tree-sitter-hl-face:constructor
                  tree-sitter-hl-face:variable.builtin))
    (set-face-attribute face nil
                        :weight 'normal
                        :foreground "#ECBE7B"
                        :slant 'normal
                        :underline nil))

  ;; bold constants
  (dolist (face '(tree-sitter-hl-face:constant.builtin
                  font-lock-constant-face
                  tree-sitter-hl-face:constant))
    (set-face-attribute face nil
                        :weight 'bold
                        :foreground "#fab387"
                        :slant 'normal
                        :underline nil))

  (set-face-attribute 'tree-sitter-hl-face:variable.parameter nil
                      :weight 'normal
                      :foreground "#eba0ac"
                      :slant 'normal
                      :underline nil)

  (set-face-attribute 'tree-sitter-hl-face:property.definition nil
                      :weight 'normal
                      :foreground "#b4befe"
                      :slant 'normal
                      :underline nil)

  (dolist (face '(tree-sitter-hl-face:function
                  tree-sitter-hl-face:function.call
                  tree-sitter-hl-face:function.macro
                  font-lock-function-name-face
                  font-lock-function-call-face
                  tree-sitter-hl-face:function.builtin
                  tree-sitter-hl-face:function.special
                  tree-sitter-hl-face:method.call))
    (set-face-attribute face nil
                        :weight 'normal
                        :foreground "#51afef"
                        :slant 'normal
                        :underline nil))

  (dolist (face '(flymake-warning
                  flymake-note
                  flymake-error))
    (set-face-attribute face nil
                        :weight 'normal
                        :slant 'normal
                        :underline nil)))

(add-hook 'lsp-after-initialize-hook 'my-customize-faces)

(set-face-attribute 'button nil
                    :weight 'normal
                    :foreground "#98be65")


;; emacs-lisp syntax highlighting
(dolist (face '(font-lock-keyword-face
                org-document-info
                dired-directory
                font-lock-builtin-face))
  (set-face-attribute face nil
                      :weight 'normal
                      :slant 'normal
                      :foreground "#cba6f7"
                      :underline nil))

;; editor font
(dolist (face '(default
                fixed-pitch
                variable-pitch))
  (set-face-attribute face nil
                      :family "Iosevka Nerd Font"
                      :height 160
                      :weight 'Regular
                      :foreground "#d8dee9"))

;; org mode heading and source block faces
(set-face-attribute 'org-document-title nil
                    :family "Iosevka Nerd Font"
                    :height 160
                    :weight 'Bold
                    :foreground "#bbc2cf")

(set-face-attribute 'org-level-1 nil
                    :family "Iosevka Nerd Font"
                    :height 160
                    :weight 'Bold)

(set-face-attribute 'org-level-2 nil
                    :family "Iosevka Nerd Font"
                    :height 160
                    :foreground "#A9A1E1"
                    :weight 'Bold)

(set-face-attribute 'org-level-3 nil
                    :family "Iosevka Nerd Font"
                    :height 160
                    :foreground "#A9A1E1"
                    :weight 'Bold)

(set-face-attribute 'org-block-begin-line nil
                    :foreground "#23272e")
