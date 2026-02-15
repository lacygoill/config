// Purpose: Devise a function that returns the sum of two integers.
// Reference: page 379 (paper) / 408 (ebook)

#include <stdio.h>

int sum(int a, int b);

    int
main(void)
{
    int a = 2;
    int b = 3;
    printf("a + b = %d\n", sum(a, b));
    return 0;
}

    int
sum(int a, int b)
{
    return a + b;
}
