// Purpose: Redo Programming Exercise 8, but this time use a recursive function.
// GCC Options: -Wno-float-equal
// Reference: page 381 (paper) / 410 (ebook)

#include <stdio.h>

double power(double n, int p);

    int
main(void)
{
    double x, xpow;
    int exp;

    printf("Enter a number and the positive power");
    printf(" to which\nthe number will be raised. Enter q");
    printf(" to quit.\n");
    while (scanf("%lf%d", &x, &exp) == 2)
    {
        xpow = power(x, exp);
        printf("%.3g to the power %d is %.5g\n", x, exp, xpow);
        printf("Enter next pair of numbers or q to quit.\n");
    }
    printf("Hope you enjoyed this power trip -- bye!\n");

    return 0;
}

    double
power(double n, int p)
{
    double pow = 1;

    if (p == 0)
    {
        pow = 1;
        if (n == 0)
            printf("It is undefined, but using value of 1.\n");
    }

    else if (p < 0)
    {
        if (n == 0)
            pow = 0;
        else
            //                            power(n, p + 1)
            //                            v--v
            // for example, 3^-4 = 3^-1 * 3^-3
            //                     ^--^
            //                     1.0 / n
            return (1.0 / n) * power(n, p + 1);
    }

    else
        return n * power(n, p - 1);

    return pow;
}
