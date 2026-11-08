// Purpose: Write and  test a `Fibonacci()` function  that uses a loop  instead of
// recursion to calculate Fibonacci numbers.
//
// Reference: page 381 (paper) / 410 (ebook)

#include <stdio.h>

unsigned long Fibonacci(unsigned n);

    int
main(void)
{
    unsigned n;
    printf("Enter an integer: ");
    scanf("%u", &n);
    printf("Fibonacci(%u) = %lu\n", n, Fibonacci(n));
}

    unsigned long
Fibonacci(unsigned n)
{
    unsigned long a = 0;
    unsigned long b = 1;
    unsigned long c;
    unsigned count;

    if (n == 0)
        return a;

    if (n == 1)
        return b;

    for (count = 2; count <= n; count++)
    {
        c = a + b;
        a = b;
        b = c;
    }

    return c;
}
