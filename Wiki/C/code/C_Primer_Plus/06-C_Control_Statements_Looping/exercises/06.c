// Purpose: Write  a program  that  prints  a table  with  each  line giving  an
// integer, its square, and its cube.  Ask the user to input the lower and upper
// limits for the table.  Use a `for` loop.
//
// Reference: page 242 (paper) / 271 (ebook)

#include <stdio.h>

    int
main(void)
{
    int lower, upper;

    printf("Enter lower limit: ");
    scanf("%d", &lower);

    printf("Enter upper limit: ");
    scanf("%d", &upper);

    printf("integer square cube\n");
    for (int i = lower; i <= upper; i++)
    {
        printf("%-7d %-6d %5d\n", i, i * i, i * i * i);
    }

    return 0;
}
