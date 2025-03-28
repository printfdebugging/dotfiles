(use-package indent-bars
  :config
    (require 'indent-bars-ts)
    (setq
     indent-bars-color                   '(highlight :face-bg t :blend 0.1)
     indent-bars-pattern                  "."
     indent-bars-width-frac               0.2
     indent-bars-pad-frac                 0.4
     indent-bars-zigzag                   nil
     indent-bars-starting-column          0
     indent-bars-color-by-depth           nil
     indent-bars-highlight-current-depth  nil
     indent-bars-display-on-blank-lines  'least)
  :custom
    (indent-bars-no-descend-lists nil)
    (indent-bars-treesit-support t)
    (indent-bars-treesit-ignore-blank-lines-types '("module"))
    :hook ((lsp-mode  . indent-bars-mode)
           (text-mode . indent-bars-mode)
           (prog-mode . indent-bars-mode)))

