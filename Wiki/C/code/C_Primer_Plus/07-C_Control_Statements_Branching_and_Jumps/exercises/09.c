// Purpose: Write a  program that accepts a  positive integer as input  and then
// displays all the prime numbers smaller than or equal to that number.
//
// Reference: page 297 (paper) / 326 (ebook)

#include <stdio.h>
#include <stdbool.h>

bool isprime(unsigned int i);

    int
main(void)
{
    unsigned int num;

    printf("Enter a positive integer: ");
    scanf("%u", &num);

    printf("Prime numbers smaller or equal than %u: ", num);
    for (unsigned int i = 2; i <= num ; i++)
    {
        if (isprime(i))
            printf("%d ", i);
    }
    return 0;
}

    bool
isprime(unsigned int i)
{
    bool isPrime = true;
    for (unsigned int div = 2; div * div <= i; div++)
        if ((i % div) == 0)
            isPrime = false;
    return isPrime;
}
