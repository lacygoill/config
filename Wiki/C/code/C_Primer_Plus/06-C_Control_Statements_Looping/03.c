// Purpose: watch your braces
// Reference: page 194 (paper) / 223 (ebook)
#include <stdio.h>

    int
main(void)
{
    int n = 0;
    while (n < 3)
        printf("n is %d\n", n);
        n++;  // without braces, `n` is never incremented, and the loop never terminates
              // the indentation doesn't matter, only braces do
    printf("That's all this program does\n");

    return 0;
}
