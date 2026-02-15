// Purpose: partially initialized array
// Reference: page 387 (paper) / 416 (ebook)

#include <stdio.h>
#define SIZE 4

    int
main(void)
{
    int some_data[SIZE] = {1492, 1066};

    printf("%2s%14s\n", "i", "some_data[i]");
    for (int i = 0; i < SIZE; i++)
        printf("%2d%14d\n", i, some_data[i]);
    //     i  some_data[i]
    //     0          1492
    //     1          1066
    //     2             0
    //     3             0
    //
    // Notice how the elements  2 and 3 were set to 0  (and not garbage values).
    // If you don't initialize an array at all, its elements, like uninitialized
    // ordinary variables, get  garbage values; but if  you partially initialize
    // an array, the remaining elements are set to 0.

    return 0;
}
