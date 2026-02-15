// Purpose: Modify exercise 8 so that it uses  a function to return the value of
// the calculation.
//
// Reference: page 242 (paper) / 271 (ebook)

#include <stdio.h>

float calculation(float f, float g);

    int
main(void)
{
    float f, g;
    printf("Enter 2 floating-point numbers: ");
    while (scanf("%f %f", &f, &g) == 2)
    {
        printf("(f - g) / (f * g) = %f\n", calculation(f, g));
        printf("Enter next floating-point numbers: ");
    }
    return 0;
}

    float
calculation(float f, float g)
{
    return (f -g) / (f * g);
}
