;; magit
(use-package magit
  :ensure t)


(use-package rainbow-mode
  :hook ((lsp-mode  . rainbow-mode)
         (text-mode . rainbow-mode)
         (prog-mode . rainbow-mode)))


(defun project-compile-custom (command)
  "custom version of the real deal that automatically runs command and switches to the compilation buffer."
  (declare (interactive-only compile))
  (interactive "sCompile command: ")
  (let* ((default-directory (project-root (project-current t)))
         (compilation-buffer-name-function
          (or project-compilation-buffer-name-function
              compilation-buffer-name-function))
         ;; Store the compilation buffer name based on the buffer naming function
         (compilation-buffer (compilation-start command nil)))
    ;; Switch to the compilation buffer after starting the compilation
    (when (bufferp compilation-buffer)
      (switch-to-buffer-other-window compilation-buffer))))

;; compile projects conveniently
(evil-define-key 'normal 'global (kbd "t") (lambda () (interactive) (project-compile-custom "make run")))
(evil-define-key 'normal 'global (kbd "T") (lambda () (interactive) (project-compile-custom "make clean")))

(setq display-buffer-alist
      '(("\\*compilation\\*" ;; Match the compilation buffer
         (display-buffer-reuse-window
          display-buffer-in-direction)
         (direction . below) ;; Horizontal split below
         (window-height . 0.5)) ;; Adjust the height percentage
        ("\\*xref\\*" ;; Match the xref buffer used for references like lsp-find-references
         (display-buffer-reuse-window
          display-buffer-in-direction)
         (direction . below) ;; Horizontal split below
         (window-height . 0.5))))


;; gdb show many windows
;; TODO: integrate gdb with exwm
(setq gdb-many-windows t
      gdb-show-main t)

(with-eval-after-load "eglot"
  (add-to-list 'eglot-stay-out-of 'eldoc))


(add-hook 'c-mode-common-hook
          (lambda ()
             (c-set-offset 'case-label '+)))


(use-package go-mode
  :ensure t)

(add-hook 'go-mode-hook (lambda ()
    (setq tab-width 4)))

(add-hook 'before-save-hook 'gofmt-before-save)
(add-hook 'go-mode-hook (lambda ()
                          (setq tab-width 4)))



(electric-pair-mode 1)
(setq auto-save-default nil)



(defun my-c-mode-hook ()
  (setq c-default-style "bsd")
  (setq c-basic-offset 4)
  (c-set-offset 'substatement-open 0))

(add-hook 'c++-mode-hook 'my-c-mode-hook)
(add-hook 'c-mode-hook 'my-c-mode-hook)

;; use lambda symbol instead of literal word in lisp
(defun sm-greek-lambda ()
  (font-lock-add-keywords nil `(("\\<lambda\\>"
                                 (0 (progn (compose-region (match-beginning 0) (match-end 0)
                                                           ,(make-char 'greek-iso8859-7 107))
                                           nil))))))

(add-hook 'emacs-lisp-mode-hook 'sm-greek-lambda)
