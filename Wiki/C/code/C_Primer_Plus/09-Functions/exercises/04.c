// Purpose: The harmonic mean of two numbers  is obtained by taking the inverses
// of the  two numbers, averaging  them, and taking  the inverse of  the result.
// Write a  function that takes  two double  arguments and returns  the harmonic
// mean of the two numbers.
//
// Reference: page 380 (paper) / 409 (ebook)

#include <stdio.h>

double harmonic(double a, double b);

    int
main(void)
{
    double a, b;
    printf("Enter two numbers: ");
    scanf("%lf%lf", &a, &b);
    printf("The harmonic of %.2f and %.2f is %.2f.\n", a, b, harmonic(a, b));
}

    double
harmonic(double a, double b)
{
    a = 1 / a;
    b = 1 / b;
    return 2 / (a + b);
}
