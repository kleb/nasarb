#define istrue(condition)\
   if (.not.(condition)) testKitHasFailed = .true.;\
   if (.not.(condition)) print *, "condition";
