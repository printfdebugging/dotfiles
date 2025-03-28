(defun my-customize-faces ()
  ;; most of the faces should be of regular weight
  (dolist (face '(tree-sitter-hl-face:doc
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
                  tree-sitter-hl-face:variable
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
                  tree-sitter-hl-face:punctuation.delimiter))
    (set-face-attribute face nil
                        :weight 'normal
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
                        :underline nil))

  (dolist (face '(tree-sitter-hl-face:type.builtin
                  tree-sitter-hl-face:constant.builtin
                  tree-sitter-hl-face:function.builtin
                  tree-sitter-hl-face:constructor
                  tree-sitter-hl-face:variable.builtin))
    (set-face-attribute face nil
                        :weight 'normal
                        :foreground "#ECBE7B"
                        :slant 'normal
                        :underline nil))

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
                      :height 150
                      :weight 'Regular
                      :foreground "#d8dee9"))

;; org mode heading and source block faces
(set-face-attribute 'org-document-title nil
                    :family "Iosevka Nerd Font"
                    :height 250
                    :weight 'Bold
                    :foreground "#bbc2cf")

(set-face-attribute 'org-level-1 nil
                    :family "Iosevka Nerd Font"
                    :height 230
                    :weight 'Bold)

(set-face-attribute 'org-level-2 nil
                    :family "Iosevka Nerd Font"
                    :height 190
                    :foreground "#A9A1E1"
                    :weight 'Bold)

(set-face-attribute 'org-level-3 nil
                    :family "Iosevka Nerd Font"
                    :height 170
                    :foreground "#A9A1E1"
                    :weight 'Bold)

(set-face-attribute 'org-block-begin-line nil
                    :foreground "#23272e")
