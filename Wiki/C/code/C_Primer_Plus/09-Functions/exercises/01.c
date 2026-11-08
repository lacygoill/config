// Purpose: Devise a function called `min(x,y)`  that returns the smaller of two
// double values.  Test the function with a simple driver.
//
// Reference: page 380 (paper) / 409 (ebook)

#include <stdio.h>
int min(int a, int b);

    int
main(void)
{
    int a, b;
    printf("Enter 2 numbers: ");
    scanf("%d%d", &a, &b);
    printf("The smaller of %d and %d is %d.\n", a, b, min(a, b));
    return 0;
}

    int
min(int a, int b)
{
    if (a < b)
        return a;
    return b;
}
