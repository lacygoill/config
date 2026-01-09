// Purpose: pointer addition
// Reference: page 399 (paper) / 428 (ebook)

#include <stdio.h>
#define SIZE 4

    int
main(void)
{
    short dates[SIZE];
    short * pti;
    short index;
    double bills[SIZE];
    double * ptf;

    pti = dates;   // assign address of array to pointer (remember that `dates` ⇔ `&dates[0]`)
    ptf = bills;
    printf("%23s %15s\n", "short", "double");
    for (index = 0; index < SIZE; index++)
        printf("pointers + %d: %10p %10p\n",
                index, (void *)(pti + index), (void *)(ptf + index));
    //                       short          double
    //     pointers + 0: 0x7ffc424bf748 0x7ffc424bf720
    //     pointers + 1: 0x7ffc424bf74a 0x7ffc424bf728
    //     pointers + 2: 0x7ffc424bf74c 0x7ffc424bf730
    //     pointers + 3: 0x7ffc424bf74e 0x7ffc424bf738
    //
    // In the first column, notice how the addresses increase by 2 bytes.
    // And in the second one, they increase by 8.
    // That's because C adds one "storage unit"  (which is 2 for a `short` and 8
    // for a `double`)  so that the address  is increased to the  address of the
    // next element, not just the next byte.

    return 0;
}
