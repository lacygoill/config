// Purpose: Modify the  guessing program of Listing  8.4 so that it  uses a more
// intelligent guessing strategy.  For example, have the program initially guess
// 50, and have it ask the user whether the guess is high, low, or correct.  If,
// say, the  guess is low, have  the next guess  be halfway between 50  and 100,
// that is, 75.  If that guess is high, let the next guess be halfway between 75
// and 50,  and so on.  Using  this binary search strategy,  the program quickly
// zeros in on the correct answer, at least if the user does not cheat.
//
// Reference: page 333 (paper) / 362 (ebook)

#include <stdio.h>

    int
main(void)
{
    int lower = 1;
    int upper = 100;
    int guess = (lower + upper) / 2;
    int response;

    printf("Pick an integer from 1 to 100. I will try to guess ");
    printf("it.\nRespond with a y if my guess is right, with an s if it\n");
    printf("is small and with a b if it is big.\n");
    printf("Uh...is your number %d?\n", guess);
    while ((response = getchar()) != 'y')
    {
        while (getchar() != '\n')
            continue;
        if (response == 's')
        {
            lower = guess;
            //     guess + (upper - guess) / 2;
            guess = (guess + upper) / 2;
        }
        else if (response == 'b')
        {
            upper = guess;
            //     lower + (guess - lower) / 2;
            guess = (guess + lower) / 2;
        }
        else
            printf("Sorry, I only understand y, s, and b.\n");

        printf("Well, then, is it %d?\n", guess);
    }
    printf("I knew I could do it!\n");
    return 0;
}
