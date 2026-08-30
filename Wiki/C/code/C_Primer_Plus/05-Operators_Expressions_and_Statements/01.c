// Purpose: converts a shoe size to inches
// Reference: page 144 (paper) / 173 (ebook)

#include <stdio.h>
#define ADJUST 7.31  // one kind of symbolic constant

    int
main(void)
{
    const double SCALE = 0.333;  // another kinf of symbolic constant
    double shoe, foot;

    shoe = 9.0;
    foot = SCALE * shoe + ADJUST;
    printf("Shoe size (men's)    foot length\n");
    printf("%10.1f %15.2f inches\n", shoe, foot);

    return 0;
}
