// Purpose: postfix vs prefix
// Reference: page 163 (paper) / 192 (ebook)

#include <stdio.h>

    int
main(void)
{
    int a = 1, b = 1;
    int a_post, pre_b;

    a_post = a++;  // value of `a++` during assignment phase
    pre_b = ++b;  // value of `++b` during assignment phase
    printf("a  a_post  b   pre_b\n");
    printf("%1d %5d %4d %5d\n", a, a_post, b, pre_b);
    //     a  a_post  b   pre_b
    //     2     1    2     2
    //
    // Notice  how `a_post`  has the  value of  `a` *before*  being incremented,
    // while `pre_b`  has the  value of `b`  *after* being  incremented.  That's
    // because the postfix `++` changes the  value after it has been used, while
    // the prefix `++` changes the value before it has been used.

    return 0;
}
