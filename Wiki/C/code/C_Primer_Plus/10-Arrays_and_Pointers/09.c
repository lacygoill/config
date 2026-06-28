// Purpose: uses pointer notation
// Reference: page 401 (paper) / 430 (ebook)

#include <stdio.h>
#define MONTHS 12

    int
main(void)
{
    int days[MONTHS] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

    for (int index = 0; index < MONTHS; index++)
        printf("Month %2d has %d days.\n", index + 1,
                *(days + index));  // same as `days[index]`

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
//     Month 11 has 30 days.
//     Month 12 has 31 days.
