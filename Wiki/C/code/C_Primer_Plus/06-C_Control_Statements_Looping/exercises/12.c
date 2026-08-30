// Purpose: Consider these two infinite series:
//
//     1.0 + 1.0/2.0 + 1.0/3.0 + 1.0/4.0 + ...
//     1.0 - 1.0/2.0 + 1.0/3.0 - 1.0/4.0 + ...
//
// Write a program that evaluates running totals  of these two series up to some
// limit of number of terms.  Hint: –1 times  itself an odd number of times is
// –1, and  –1 times itself  an even  number of times  is 1.  Have  the user
// enter the limit interactively; let a  zero or negative value terminate input.
// Look at the  running totals after 100 terms, 1000  terms, 10,000 terms.  Does
// either series appear to be converging to some value?
//
// GCC Options: -Wno-strict-overflow
//
// Reference: page 243 (paper) / 272 (ebook)

#include <stdio.h>

    int
main(void)
{
    int n, sign;
    double sum1, sum2;

    printf("Enter the number of terms: ");
    while (scanf("%d", &n) == 1 && n > 0)
    {
        sum1 = 0;
        sum2 = 0;
        sign = 1;

        for (int i = 1; i <= n; i++)
            sum1 += 1.0 / (double)i;
        // `sum1` does not converge.
        printf("sum1 is: %f\n", sum1);

        for (int i = 1; i <= n; i++, sign *= -1)
            sum2 += sign * 1.0 / (double)i;
        // `sum2` converges towards 0.693147.
        printf("sum2 is: %f\n", sum2);

        printf("Enter next number of terms: ");
    }

    return 0;
}
