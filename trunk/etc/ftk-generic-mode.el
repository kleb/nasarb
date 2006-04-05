;; Make a generic-mode for Fortran TK files:
(require 'generic)
(define-generic-mode 'ftk-generic-mode
   (list ?!)
   (list
    "beginTest"
    "endTest"
    "beginSetup"
    "endSetup"
    "beginTeardown"
    "endTeardown"
   )
   '(("\\(IsFalse\\)"		1	'font-lock-function-name-face)
     ("\\(IsTrue\\)"		1	'font-lock-function-name-face)
     ("\\(IsEqualWithin\\)"	1	'font-lock-function-name-face)
     ("\\(IsEqual\\)"		1	'font-lock-function-name-face)
     ("\\(IsRealEqual\\)"	1	'font-lock-function-name-face))
   (list "\\.ftk\\'")
   nil
   "Generic mode for Fortran Test Kit files.")
