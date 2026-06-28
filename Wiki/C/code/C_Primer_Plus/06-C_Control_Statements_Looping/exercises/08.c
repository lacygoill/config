// Purpose: Write a program that requests  two floating-point numbers and prints
// the value  of their difference  divided by  their product.  Have  the program
// loop through pairs of input values until the user enters non-numeric input.
//
// Reference: page 242 (paper) / 271 (ebook)

#include <stdio.h>

    int
main(void)
{
    float f, g;
    printf("Enter 2 floating-point numbers: ");
    while (scanf("%f %f", &f, &g) == 2)
    {
        printf("(f - g) / (f * g) = %f\n", (f -g) / (f * g));
        printf("Enter next floating-point numbers: ");
    }
    return 0;
}
