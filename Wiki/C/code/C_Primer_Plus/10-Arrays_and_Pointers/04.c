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
//     Month  1 has 31 days.
//     Month  2 has 28 days.
//     Month  3 has 31 days.
//     Month  4 has 30 days.
//     Month  5 has 31 days.
//     Month  6 has 30 days.
//     Month  7 has 31 days.
//     Month  8 has 31 days.
//     Month  9 has 30 days.
//     Month 10 has 31 days.
