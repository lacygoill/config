// Purpose: uninitialized array
// Reference: page 386 (paper) / 415 (ebook)

#include <stdio.h>
#define SIZE 4

    int
main(void)
{
    int no_data[SIZE];  // uninitialized array

    printf("%2s%14s\n", "i", "no_data[i]");
    for (int i = 0; i < SIZE; i++)
        printf("%2d%14d\n", i, no_data[i]);

    return 0;
}
//     i    no_data[i]
//     0             0
//     1             0
//     2    -870787200
//     3         32549
