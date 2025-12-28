// Purpose: letting the compiler count elements
// Reference: page 387 (paper) / 416 (ebook)

#include <stdio.h>

    int
main(void)
{
    // When you use  empty brackets to initialize an array,  the compiler counts
    // the number of items in the list and makes the array that large.
    //            vv
    const int days[] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31};
    unsigned index;
    for (index = 0; index < sizeof(days) / sizeof(days[0]); index++)
    //                      ^----------------------------^
    //                      let the compiler count the number of elements
        printf("Month %2d has %d days.\n", index + 1, days[index]);

    return 0;
}
