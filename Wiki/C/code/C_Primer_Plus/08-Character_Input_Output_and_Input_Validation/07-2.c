// Purpose: get and validate numerical limits
// Reference: page 319 (paper) / 348 (ebook)

#include <stdio.h>
#include <stdbool.h>

bool bad_limits(long begin, long end, long low, long high);

    int
main(void)
{
    const long MIN = -10000000L;
    const long MAX = 10000000L;
    long start;
    long stop;

    printf("lower limit: ");
    scanf("%ld", &start);
    printf("upper limit: ");
    scanf("%ld", &stop);

    while (start != 0 || stop != 0)
    {
        if (bad_limits(start, stop, MIN, MAX))
            printf("Please, try again.\n");
        else
            printf("The limits are valid.\n");
        printf("lower limit: ");
        scanf("%ld", &start);
        printf("upper limit: ");
        scanf("%ld", &stop);
    }

    printf("Done.\n");

    return 0;
}

    bool
bad_limits(long begin, long end, long low, long high)
{
    bool not_good = false;
    if (begin > end)
    {
        printf("%ld isn't smaller than %ld.\n", begin, end);
        not_good = true;
    }
    if (begin < low || end < low)
    {
        printf("Values must be %ld or greater.\n", low);
        not_good = true;
    }
    if (begin > high || end > high)
    {
        printf("Values must be %ld or less.\n", high);
        not_good = true;
    }

    return not_good;
}
