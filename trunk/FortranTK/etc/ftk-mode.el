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

(defvar ftk-buffer-command "FTKtest"
  "Shell command used by the \\[ftk-test-buffer] function.")

;; run FTK on the current buffer:
(defun ftk-test-buffer ()
  "Excute \\[ftk-buffer-command] on the file associated
   with the current buffer."
  (interactive)
  (save-buffer)
  (shell-command-on-region (point-min) (point-max) ftk-buffer-command)
)

;; key-binding for running FTK on the current buffer
(define-key ftk-mode-map "\C-c\C-c" 'ftk-test-buffer)

(provide 'ftk-mode)

;; end of 'ftk-mode.el'
