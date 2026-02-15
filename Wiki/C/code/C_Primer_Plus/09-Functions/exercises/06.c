// Purpose: Write and test  a function that takes the addresses  of three double
// variables as arguments and that moves the value of the smallest variable into
// the first variable, the middle value  to the second variable, and the largest
// value into the third variable.
//
// Reference: page 381 (paper) / 410 (ebook)

#include <stdio.h>

void sort(double * x, double * y, double * z);

    int
main(void)
{
    double x, y, z;

    printf("Enter 3 numbers: ");
    scanf("%lf%lf%lf", &x, &y, &z);
    printf("x = %.2f, y = %.2f, z = %.2f\n", x, y, z);

    sort(&x, &y, &z);

    printf("Now x = %.2f, y = %.2f, z = %.2f\n", x, y, z);

    return 0;
}

    void
sort(double * x, double * y, double * z)
{
    double temp;

    // first, let's sort `x` and `y`
    if (*y < *x)
    {
        temp = *x;
        *x = *y;
        *y = temp;
    }

    // next, let's sort `x` and `z`
    if (*z < *x)
    {
        temp = *x;
        *x = *z;
        *z = temp;
    }

    // Now, we know that `x` has the  smallest value.  But we don't know whether
    // `y` and `z` are in the right order; let's check it out.
    if (*z < *y)
    {
        temp = *y;
        *y = *z;
        *z = temp;
    }
}
