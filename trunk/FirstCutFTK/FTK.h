#define IsTrue(condition)\
   if (.not.(condition)) testKitHasFailed = .true.;\
   if (.not.(condition)) print *, "FAILURE: condition (", condition, ") is not true";

#define IsFalse(condition)\
   if (condition) testKitHasFailed = .true.;\
   if (condition) print *, "FAILURE: condition (", condition, ") is not false";

#define IsEqual(arg1,arg2)\
   if (.not.(arg1==arg2))  testKitHasFailed = .true.;\
   if (.not.(arg1==arg2)) print *, "FAILURE: arg1 (", arg1, ") is not arg2";

#define IsFloatEqual(arg1,arg2,tolerance)\
   if (.not.(arg2+tolerance.ge.arg1.and.arg2-tolerance.le.arg1))  testKitHasFailed = .true.;\
   if (.not.(arg2+tolerance.ge.arg1.and.arg2-tolerance.le.arg1)) print *, "FAILURE: arg1 (",arg1,") is not arg2 within tolerance";
