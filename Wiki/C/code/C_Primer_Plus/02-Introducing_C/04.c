// Purpose: spot bugs in a program
// Reference: page 46 (paper) / 75 (ebook)

#include <stdio.h>

    int
main(void)
( // ✘ should be curly bracket
    int n, int n2, int n3;  // ✘ you can't repeat `int` in a single declaration

/* this program has several errors  ✘ the ending `*/` is missing

    n = 5;
    n2 = n * n;
    n3 = n2 * n2;  // ✘ this is not n cubed, but the fourth power of n
    printf("n = %d, n squared = %d, n cubed = %d\n", n, n2, n3)  // ✘ the trailing semicolon is missing

    return 0;
)
