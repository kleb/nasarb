;; 'funit-mode.el' - a derived major mode for editing fUnit files
;;
;; INSTALLATION:
;;
;; 1) Copy 'funit-mode.el' to the system site-lisp directory, e.g.,
;;
;;   /usr/share/emacs/site-lisp
;;
;; or, if you do not have root permission, somewhere local
;; and set the load-path search variable in your ~/.emacs file
;; accordingly, e.g.,
;;
;;  (setq load-path (append load-path '("~/lisp")))
;;
;; 2) To automatically activate funit-mode when visiting files,
;; add the following lines to your ~/.emacs file:
;;
;;  (autoload 'funit-mode "funit-mode"
;;     "Mode for editing fUnit files.")
;;  (setq auto-mode-alist
;;     (cons '("\\.fun$" . funit-mode) auto-mode-alist))

(define-derived-mode funit-mode
  f90-mode  "fUnit"
  "Major mode for fUnit files (derived from F90 mode).\n\n
  \\{funit-mode-map}"
  (interactive)
  (message "fUnit mode.")
)

;; add some new font-locks to f90's extensive list
(font-lock-add-keywords 'funit-mode
 '(("\\<Assert_False\\>"	. font-lock-function-name-face)
   ("\\<Assert_Equal\\>"	. font-lock-function-name-face)
   ("\\<Assert_Real_Equal\\>"	. font-lock-function-name-face)
   ("\\<Assert_True\\>"		. font-lock-function-name-face)
   ("\\<Assert_Equal_Within\\>"	. font-lock-function-name-face)
   ("\\<test_suite\\>"		. font-lock-builtin-face)
   ("\\<end test_suite\\>"	. font-lock-builtin-face)
   ("\\<test\\>"		. font-lock-builtin-face)
   ("\\<end test\\>"		. font-lock-builtin-face)
   ("\\<teardown\\>"		. font-lock-builtin-face)
   ("\\<end teardown\\>"	. font-lock-builtin-face)
   ("\\<setup\\>"		. font-lock-builtin-face)
   ("\\<end setup\\>"		. font-lock-builtin-face))
)

(defvar funit-buffer-command "funit"
  "Shell command used by the \\[funit-test-buffer] function.")

;;(defvar compilation-buffer-name-function "* fUnit output *")

;; run fUnit on the current buffer:
(defun funit-test-buffer ()
  "Excute \\[funit-buffer-command] on the file associated
   with the current buffer."
  (interactive)
;  (compile funit-buffer-command);; (file-name-nondirectory buffer-file-name)))
  (save-buffer)
  (shell-command-on-region (point-min) (point-max) funit-buffer-command funit-error-buffer)
)

;; key-binding for running fUnit on the current buffer
(define-key funit-mode-map "\C-c\C-c" 'funit-test-buffer)

;; add fUnit error regex to compilation mode:
;;   blah, blah, blak [FluxFunctions.fun:34]
;(require 'compile)
;(setq compilation-error-regexp-alist
;      (cons '("\\[\\(.+\\):\\([0-9]+\\)\\]" 1 2) compilation-error-regexp-alist)
;)

(defvar funit-error-buffer
  "*fUnit output-buffer*"
  "Buffer name for error messages used by `funit-next-error'")

(defvar funit-error-message-regexp
  "\\[.+:\\([0-9]+\\)\\]"
  "Regular expression used by `funit-next-error' to find error messages.
The sub-expression between the first capturing parens must be the line
number where the error occured")

(defun funit-next-error ()
  "Goto line in current buffer indicated by next error message in `funit-error-buffer'

Assumes that the point is positioned before the first occurance of
`funit-error-message-regexp' in the `funit-error-buffer' before the first
call to this function.

See also `funit-error-message-regexp' `funit-error-buffer'"
  
  (interactive)
  (let ((error-line-number))
    (save-current-buffer
      (set-buffer (or (get-buffer funit-error-buffer)
                      (error
                       (concat
                        "Can't find the error buffer: "
                        funit-error-buffer))))
      (if (re-search-forward funit-error-message-regexp nil t)
          (progn
            (setq error-line-number
                  (string-to-number
                   (buffer-substring (match-beginning 1)
                                     (match-end 1))))
            (goto-char (1+ (match-end 1))))))
    (if error-line-number
        (goto-line error-line-number)
      (message "No more errors"))))

(provide 'funit-mode)

;; end of 'funit-mode.el'
