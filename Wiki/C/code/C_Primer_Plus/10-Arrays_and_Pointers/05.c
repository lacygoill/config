// Purpose: use designated initializers
// GCC Options: -Wno-override-init
// Reference: page 389 (paper) / 418 (ebook)

#include <stdio.h>
#define MONTHS 12

    int
main(void)
{
    int days[MONTHS] = {31, 28, [4] = 31, 30, 31, [1] = 29};

    for (int i = 0; i < MONTHS; i++)
        printf("%2d  %d\n", i + 1, days[i]);

    return 0;
}
//     1  31
//     2  29
//     3  0
//     4  0
//     5  31
//     6  30
//     7  31
//     8  0
//     9  0
//     10  0
//     11  0
//     12  0
