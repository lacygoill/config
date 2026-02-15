// Purpose: precedence test
// Reference: page 156 (paper) / 185 (ebook)

#include <stdio.h>

    int
main(void)
{
    int top, score;

    top = score = -(2 + 5) * 6 + (4 + 3 * (2 + 3));
    printf("top = %d, score = %d\n", top, score);

    return 0;
}
