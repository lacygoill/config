// Purpose: what values are true?
// Reference: page 200 (paper) / 229 (ebook)

#include <stdio.h>

    int
main(void)
{
    int n = 3;

    while (n)
        printf("%2d is true\n", n--);
    printf("%2d is false\n", n);
    //     3 is true
    //     2 is true
    //     1 is true
    //     0 is false

    n = -3;
    while (n)
        printf("%2d is true\n", n++);
    printf("%2d is false\n", n);
   //     -3 is true
   //     -2 is true
   //     -1 is true
   //     0 is false

   // All numbers are true, except 0.

    return 0;
}
