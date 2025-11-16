// Purpose: compute various arithmetic expressions
// GCC Options: -Wno-float-conversion -Wno-sequence-point
// Reference: page 70 (paper) / 95 (ebook)

#include <stdio.h>

    int
main(void)
{
    int i, j;

    i = 6;
    j = i += i;
    printf("%d %d\n", i, j);
    //     12 12
    // There is no UB here.{{{
    //
    // Even though we have an expression which simultaneously modifies and reads
    // `i` (`i += i`).  There  would be an issue  if `i` was read  or written to
    // from outside this compound assignment.  But it's not.
    // }}}

    i = 5;
    j = (i -= 2) + 1;
    printf("%d %d\n", i, j);
    //     3 4

    i = 7;
    j = 6 + (i = 2.5);
    printf("%d %d\n", i, j);
    //     2 8

    i = 2; j = 8;
    j = (i = 6) + (j = 3);
    printf("%d %d\n", i, j);
    //     6 9
    //
    // Warning: In reality, this causes UB.
    //
    //     operation on ‘j’ may be undefined [-Werror=sequence-point]
    //
    // `j = 3` is evaluated  *and* has a side-effect (assignment  to `j`).  Yes,
    // the *evaluation* occurs before the outer assignment to `j`.  But there is
    // no guarantee that the *side-effect*  (assignment) occurs before the outer
    // one.   C does  not specify  the order  of side-effects  in an  expression
    // without sequence point.

    return 0;
}
