// Purpose: prints Fibonacci numbers
// Reference: page 361 (paper) / 390 (ebook)

// Be cautious when using recursion, particularly when efficiency is important.{{{
//
// Here, suppose you  use the function call `Fibonacci(40)`.  That  would be the
// first level  of recursion, and it  allocates a variable called  `n`.  It then
// invokes `Fibonacci()`  twice, creating two  more variables called `n`  at the
// second level of recursion.  Each of those two calls generates two more calls,
// requiring four more variables called `n` at the third level of recursion, for
// a  total  of seven  variables.   Each  level  requires  twice the  number  of
// variables  as  the  preceding  level,  and  the  number  of  variables  grows
// exponentially.  Exponential  growth soon leads  to the computer  requiring an
// enormous amount of memory, most likely causing the program to crash.
//}}}

#include <stdio.h>

unsigned long fibonacci(unsigned long n);

    int
main(void)
{
    unsigned long number;
    printf("Enter an integer (q to quit):\n");
    while (scanf("%lu", &number) == 1)
    {
        printf("Fibonacci number: ");
        printf("%lu", fibonacci(number));
        putchar('\n');
        printf("Enter an integer (q to quit):\n");
    }
    printf("Done.\n");

    return 0;
}

    unsigned long
fibonacci(unsigned long n)
{
    if (n <= 2)
        return 1;
    return fibonacci(n - 1) + fibonacci(n - 2);
}
