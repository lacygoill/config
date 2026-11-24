// Purpose: Write a function that returns the largest of three integer arguments.
// Reference: page 380 (paper) / 409 (ebook)
#include <stdio.h>

int max(int a, int b, int c);

    int
main(void)
{
    int a = 3;
    int b = 9;
    int c = 6;
    printf("The largest number between %d, %d, and %d is %d.\n",
            a, b, c, max(a, b, c));
    return 0;
}

    int
max(int a, int b, int c)
{
    int max = a;

    if (b > max)
        max = b;
    if (c > max)
        max = c;

    return max;
}
