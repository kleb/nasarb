;; Make a generic-mode for fUnit files:
(require 'generic)
(define-generic-mode 'funit-generic-mode
   (list ?!)
   (list
    "test_suite"
    "end test_suite"
    "test"
    "end test"
    "setup"
    "end setup"
    "teardown"
    "end teardown"
   )
   '(("\\(Assert_False\\)"		1	'font-lock-function-name-face)
     ("\\(Assert_True\\)"		1	'font-lock-function-name-face)
     ("\\(Assert_Equal_Within\\)"	1	'font-lock-function-name-face)
     ("\\(Assert_Equal\\)"		1	'font-lock-function-name-face)
     ("\\(Assert_Real_Equal\\)"	1	'font-lock-function-name-face))
   (list "\\.fun\\'")
   nil
   "Generic mode for fUnit files.")
