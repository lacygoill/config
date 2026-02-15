// Purpose: Devise a function  called `alter()` that takes  two `int` variables,
// `x` and  `y`, and  changes their  values to their  sum and  their difference,
// respectively.
//
// Reference: page 379 (paper) / 408 (ebook)

#include <stdio.h>

void alter(int * a, int * b);

    int
main(void)
{
    int x = 2;
    int y = 3;
    printf("x = %d and y = %d.\n", x, y);
    alter(&x, &y);
    printf("Now x = %d and y = %d.\n", x, y);
    return 0;
}

    void
alter(int * pa, int * pb)
{
    int temp = *pa + *pb;
    *pb = *pa - *pb;
    *pa = temp;
}
