// Purpose: What changes, if any, would you need to make to have the function of
// question 4 add two double numbers instead?
//
// Reference: page 379 (paper) / 408 (ebook)

#include <stdio.h>

double sum(double a, double b);

    int
main(void)
{
    double a = 2;
    double b = 3;
    printf("a + b = %.2f\n", sum(a, b));
    return 0;
}

    double
sum(double a, double b)
{
    return a + b;
}
