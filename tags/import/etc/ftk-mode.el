;; 'ftk-mode.el' - a derived major mode for editing Fortran Test Kit files
;;
;; $Id$
;;
;; INSTALLATION:
;;
;; Copy 'ftk-mode.el' to the system site-lisp directory, e.g.,
;;
;;   /usr/share/emacs/site-lisp
;;
;; or, if you do not have root permission, somewhere local
;; and set the load-path search variable in your ~/.emacs file
;; accordingly, e.g.,
;;
;;  (setq load-path (append load-path '("~/lisp")))
;;
;; Then, to automatically activate ftk-mode when visiting files,
;; add the following lines to your ~/.emacs file:
;;
;;  (autoload 'ftk-mode "ftk-mode"
;;     "Mode for editing Fortran Test Kit files.")
;;  (setq auto-mode-alist
;;     (cons '("\\TS.ftk$" . ftk-mode) auto-mode-alist))

(define-derived-mode ftk-mode
  f90-mode  "FortranTK"
  "Major mode for Fortran Test Kit files (derived from F90 mode).\n\n
  \\{ftk-mode-map}"
  (interactive)
  (message "Fortran Test Kit mode.")
)

;; add some new font-locks to f90's extensive list
(font-lock-add-keywords 'ftk-mode
 '(("\\<IsFalse\\>"		. font-lock-function-name-face)
   ("\\<IsEqual\\>"		. font-lock-function-name-face)
   ("\\<IsRealEqual\\>"		. font-lock-function-name-face)
   ("\\<IsTrue\\>"		. font-lock-function-name-face)
   ("\\<IsEqualWithin\\>"	. font-lock-function-name-face)
   ("\\<beginTest\\>"		. font-lock-builtin-face)
   ("\\<endTest\\>"		. font-lock-builtin-face)
   ("\\<beginTeardown\\>"	. font-lock-builtin-face)
   ("\\<endTeardown\\>"		. font-lock-builtin-face)
   ("\\<beginSetup\\>"		. font-lock-builtin-face)
   ("\\<endSetup\\>"		. font-lock-builtin-face))
)

(defvar ftk-buffer-command "F90test"
  "Shell command used by the \\[ftk-test-buffer] function.")

;;(defvar compilation-buffer-name-function "* F90unit output *")

;; run FTK on the current buffer:
(defun ftk-test-buffer ()
  "Excute \\[ftk-buffer-command] on the file associated
   with the current buffer."
  (interactive)
;  (compile ftk-buffer-command);; (file-name-nondirectory buffer-file-name)))
  (save-buffer)
  (shell-command-on-region (point-min) (point-max) ftk-buffer-command ftk-error-buffer)
)

;; key-binding for running FTK on the current buffer
(define-key ftk-mode-map "\C-c\C-c" 'ftk-test-buffer)

;; add F90unit error regex to compilation mode:
;;   blah, blah, blak [FluxFunctionsTS.ftk:34]
;(require 'compile)
;(setq compilation-error-regexp-alist
;      (cons '("\\[\\(.+\\):\\([0-9]+\\)\\]" 1 2) compilation-error-regexp-alist)
;)


(defvar ftk-error-buffer
  "*F90unit output-buffer*"
  "Buffer name for error messages used by `ftk-next-error'")

(defvar ftk-error-message-regexp
  "\\[.+:\\([0-9]+\\)\\]"
  "Regular expression used by `ftk-next-error' to find error messages.
The sub-expression between the first capturing parens must be the line
number where the error occured")


(defun ftk-next-error ()
  "Goto line in current buffer indicated by next error message in `ftk-error-buffer'

Assumes that the point is positioned before the first occurance of
`ftk-error-message-regexp' in the `ftk-error-buffer' before the first
call to this function.

See also `ftk-error-message-regexp' `ftk-error-buffer'"
  
  (interactive)
  (let ((error-line-number))
    (save-current-buffer
      (set-buffer (or (get-buffer ftk-error-buffer)
                      (error
                       (concat
                        "Can't find the error buffer: "
                        ftk-error-buffer))))
      (if (re-search-forward ftk-error-message-regexp nil t)
          (progn
            (setq error-line-number
                  (string-to-number
                   (buffer-substring (match-beginning 1)
                                     (match-end 1))))
            (goto-char (1+ (match-end 1))))))
    (if error-line-number
        (goto-line error-line-number)
      (message "No more errors"))))

(provide 'ftk-mode)

;; end of 'ftk-mode.el'
