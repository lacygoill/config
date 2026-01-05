// Purpose: prints the days for each month
// Reference: page 385 (paper) / 414 (ebook)

#include <stdio.h>
#define MONTHS 12

    int
main(void)
{
    int days[MONTHS] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
    int index;

    for (index = 0; index < MONTHS; index++)
        printf("Month %d has %2d days.\n", index + 1, days[index]);

    return 0;
}
