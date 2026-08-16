// Purpose: using pointers to make swapping work
// Reference: page 373 (paper) / 402 (ebook)

#include <stdio.h>
void interchange(int * u, int * v);  // declare function

    int
main(void)
{
    int x = 5, y = 10;

    printf("Originally x = %d and y = %d.\n", x, y);
    interchange(&x, &y);   // send addresses to function
    printf("Now x = %d and y = %d.\n", x, y);

    return 0;
}

void interchange(int * u, int * v)  // define function
{
    int temp;

    temp = *u;       // `temp` gets value that `u` points to
    *u = *v;
    *v = temp;
}
