// Purpose: Write a program that reads in  a floating-point number and prints it
// first in decimal-point  notation and then in exponential  notation.  Have the
// output use the following formats (the  number of digits shown in the exponent
// may be different for your system):
//
//     a. The input is 21.3 or 2.1e+001
//     b. The input is +21.290 or 2.129E+001
//
// Reference: page 141 (paper) / 170 (ebook)

#include <stdio.h>

    int
main(void)
{
    float f;

    printf("Enter a float: ");
    scanf("%f", &f);
    printf("The input is %.1f or %.1e\n", f, f);

    printf("Enter a float: ");
    scanf("%f", &f);
    printf("The input is %+.3f or %.3E\n", f, f);

    return 0;
}
