// Purpose: What will the following program print?
// Reference: page 185 (paper) / 214 (ebook)

#include <stdio.h>

    int
main(void)
{
    char c1, c2;
    int diff;
    float num;

    c1 = 'S';  // int 83
    c2 = 'O';  // int 79
    diff = c1 - c2;  // = 4
    num = (float)diff;
    printf("%c%c%c:%d %3.2f\n", c1, c2, c1, diff, num);
    //     SOS:4 4.00

    return 0;
}
