// Purpose: exponential growth
// Reference: page 151 (paper) / 180 (ebook)

#include <stdio.h>
#define SQUARES 64  // squares on a checkerboard

    int
main(void)
{
    const double CROP = 2E16;  // world wheat production in wheat grains
    double current, total;
    int count = 1;

    printf("square     grains       total     ");
    printf("fraction of \n");
    printf("           added        grains    ");
    printf("world total\n");
    total = current  = 1.0;  // start with one grain
    while (count <= SQUARES)
    {
        printf("%4d %13.2e %12.2e %12.2e\n", count, current, total, total / CROP);
        // double grains on next square
        current *= 2.0
        // update total
        total += current;
        ++count;
    }

    printf("That's all.\n");

    return 0;
}
