// Purpose: Chuckie Lucky won  a million dollars (after taxes),  which he places
// in an account  that earns 8% a year.   On the last day of  each year, Chuckie
// withdraws $100,000.  Write  a program that finds out how  many years it takes
// for Chuckie to empty his account.
//
// Reference: page 244 (paper) / 273 (ebook)

#include <stdio.h>

#define INITIAL_MONEY 1000000
#define RATE 1.08f
#define WITHDRAW 100000

    int
main(void)
{
    int years = 0;
    float account = INITIAL_MONEY;
    while (account > 0)
    {
        account *= RATE;
        account -= WITHDRAW;
        years++;
    }
    printf("Chuckie's account is empty after %d years.\n", years);
    return 0;
}
