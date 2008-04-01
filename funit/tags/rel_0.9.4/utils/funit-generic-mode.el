;; Make a generic-mode for fUnit files:
(require 'generic)
(define-generic-mode 'funit-generic-mode
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
   (list "\\.fun\\'")
   nil
   "Generic mode for fUnit files.")
