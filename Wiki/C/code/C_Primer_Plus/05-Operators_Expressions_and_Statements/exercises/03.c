// Purpose: Write a program that  asks the user to enter the  number of days and
// then converts that value to weeks and days.  For example, it would convert 18
// days to 2 weeks, 4 days.  Display results in the following format:
//
//     18 days are 2 weeks, 4 days.
//
// Reference: page 187 (paper) / 216 (ebook)

#include <stdio.h>
#define DAYS_IN_WEEK 7

    int
main(void)
{
    int days, weeks, left;
    printf("Enter a number of days: ");
    scanf("%d", &days);
    while (days > 0)
    {
        weeks = days / DAYS_IN_WEEK;
        left = days % DAYS_IN_WEEK;
        printf("%d days are %d weeks, %d days.\n", days, weeks, left);
        printf("Next number of days? ");
        scanf("%d", &days);
    }

    return 0;
}
