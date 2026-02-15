// Purpose: field widths
// Reference: page 118 (paper) / 147 (ebook)

#include <stdio.h>
#define PAGES 959

    int
main(void)
{
    printf("*%d*\n", PAGES);
    printf("*%2d*\n", PAGES);
    printf("*%10d*\n", PAGES);
    printf("*%-10d*\n", PAGES);
    //     *959*
    //     *959*
    //     *       959*
    //     *959       *

    return 0;
}
