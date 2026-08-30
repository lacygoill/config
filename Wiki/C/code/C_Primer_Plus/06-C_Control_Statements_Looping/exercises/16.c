// Purpose: Daphne invests $100  at 10% simple interest.  (That  is, every year,
// the investment  earns an interest equal  to 10% of the  original investment.)
// Deirdre invests $100 at 5%  interest compounded annually.  (That is, interest
// is  5% of  the current  balance,  including previous  addition of  interest.)
// Write a program that finds how many years it takes for the value of Deirdre's
// investment to  exceed the value  of Daphne's  investment.  Also show  the two
// values at that time.
//
// Reference: page 243 (paper) / 272 (ebook)

#include <stdio.h>

#define ORIGINAL_INVESTMENT
#define RATE 1.05f

    int
main(void)
{
    int years = 0;
    float daphne, deirdre;
    daphne = deirdre = ORIGINAL_INVESTMENT;
    while (deirdre <= daphne)
    {
        daphne += 10.0f;
        deirdre *= RATE;
        years++;
    }
    printf("After %d years, Daphne's investment is $%.2f,"
            " while Deirdre's investment is $%.2f.\n",
            years, daphne, deirdre);
    return 0;
}
