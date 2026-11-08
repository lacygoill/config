// Purpose: first-class postage rates
// Reference: page 216 (paper) / 245 (ebook)

#include <stdio.h>

    int
main(void)
{
    // 46 cents for the first ounce
    const int FIRST_OZ = 46;
    // 20 cents for each additional ounce
    const int NEXT_OZ = 20;
    int ounces, cost;

    printf(" ounces cost\n");
    for (ounces = 1, cost = FIRST_OZ; ounces <= 16; ounces++, cost += NEXT_OZ)
    //             ^                                        ^
    // the comma operator lets you write multiple inits and updates
        printf("%5d   $%4.2f\n", ounces, cost / 100.0);

    return 0;
}
