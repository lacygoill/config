// Purpose: Generalize  the   `to_binary()`  function   of  Listing  9.8   to  a
// `to_base_n()` function that takes a second  argument in the range 2–10.  It
// then should print  the number that is  its first argument to  the number base
// given by the second argument.  For example, `to_ base_n(129,8)` would display
// 201, the base-8 equivalent of 129.  Test the function in a complete program.
//
// Reference: page 381 (paper) / 410 (ebook)

#include <stdio.h>

void to_base_n(unsigned long n, unsigned int base);

    int
main(void)
{
    unsigned long number;
    unsigned int base;

    printf("Enter an integer and a base from 2 to 10 (q to quit):\n");
    while (scanf("%lu%u", &number, &base) == 2)
    {
        if (base < 2 || base > 10)
            printf("The base must be between 2 and 10.\n");
        else
        {
            printf("Equivalent in base %d: ", base);
            to_base_n(number, base);
            putchar('\n');
        }
        printf("Enter an integer and a base from 2 to 10 (q to quit):\n");
    }
    printf("Done.\n");

    return 0;
}

    void
to_base_n(unsigned long n, unsigned int base)
{
    long unsigned int r;
    r = n % base;
    if (n >= base)
        to_base_n(n / base, base);
    printf("%ld", r);
}
