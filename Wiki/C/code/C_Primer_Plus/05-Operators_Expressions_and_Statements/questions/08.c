// Purpose: What will this program print?
// Reference: page 185 (paper) / 214 (ebook)

#include <stdio.h>
#define TEN 10

    int
main(void)
{
    int n = 0;

    while (n++ < TEN)
        printf("%5d", n);
    printf("\n");
    //         1    2    3    4    5    6    7    8    9   10

    return 0;
}
