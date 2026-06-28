// Purpose: Write and  test a  function called  `larger_of()` that  replaces the
// contents of  two double variables  with the maximum  of the two  values.  For
// example, `larger_of(x,y)` would  reset both `x` and `y` to  the larger of the
// two.
//
// Reference: page 380 (paper) / 409 (ebook)

#include <stdio.h>

void larger_of(double * x, double * y);

    int
main(void)
{
    double x, y;

    printf("Enter two numbers: ");
    scanf("%lf%lf", &x, &y);
    printf("x and y are: %.2f %.2f.\n", x, y);

    larger_of(&x, &y);
    printf("Now x and y are: %.2f %.2f.\n", x, y);

    return 0;
}

    void
larger_of(double * x, double * y)
{
    double max;
    if (*x > *y)
        max = *x;
    else
        max = *y;

    *x = max;
    *y = max;
}
