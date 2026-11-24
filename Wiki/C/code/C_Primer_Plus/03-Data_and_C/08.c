// Purpose: demonstrates round-off error
// Reference: page 84 (paper) / 113 (ebook)

#include <stdio.h>

    int
main(void)
{
    float a, b;
    b = 2.0e20 + 1.0;
    a = b - 2.0e20;
    printf("%f \n", a);
    return 0;
}
