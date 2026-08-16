// Purpose: exceed the bounds of an array
// GCC Options: -Wno-aggressive-loop-optimizations
// Reference: page 391 (paper) / 420 (ebook)

#include <stdio.h>
#define SIZE 4

    int
main(void)
{
    int value1 = 44;
    int arr[SIZE];
    int value2 = 88;

    printf("value1 = %d, value2 = %d\n", value1, value2);
    for (int i = -1; i <= SIZE; i++)
        arr[i] = 2 * i + 1;

    for (int i = -1; i < 7; i++)
        printf("%2d  %d\n", i, arr[i]);
    printf("value1 = %d, value2 = %d\n", value1, value2);
    printf("address of arr[-1]: %p\n", (void *)&arr[-1]);
    printf("address of arr[4]: %p\n", (void *)&arr[4]);
    printf("address of value1: %p\n", (void *)&value1);
    printf("address of value2: %p\n", (void *)&value2);
    //     value1 = 44, value2 = 88
    //     -1  -1
    //      0  1
    //      1  3
    //      2  5
    //      3  7
    //      4  9
    //      5  0
    //      6  461612928
    //     value1 = 44, value2 = -1
    //     address of arr[-1]: 0x7ffdaab196fc
    //     address of arr[4]: 0x7ffdaab19710
    //     address of value1: 0x7ffdaab1971c
    //     address of value2: 0x7ffdaab196fc
    //
    // Notice how `value2` has been stored  just before the array (`arr[-1]` and
    // `value2`  have the  same address).   As a  result, when  you assigned  to
    // `arr[-1]`,  you accidentally  changed  `value2` (from  88  to -1).   More
    // generally, using a bad index is undefined.
    //
    // Moral of the  story: make sure to  use valid indices, because  C does not
    // check arrays' bounds (that allows a C program to run faster).
    //
    // One simple habit  to develop is to  use a symbolic constant  in the array
    // declaration and in other places where the array size is used.
    //
    //     #define SIZE 123
    //     int arr[SIZE];
    //     for (i = 0; i < SIZE; i++)
    //         arr[i] = ...;

    return 0;
}
