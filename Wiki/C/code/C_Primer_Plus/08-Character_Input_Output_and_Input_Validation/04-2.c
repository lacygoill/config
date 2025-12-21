// Purpose: a better number-guesser
// Reference: page 312 (paper) / 341 (ebook)

#include <stdio.h>

    int
main(void)
{
    int guess = 1;
    int response;

    printf("Pick an integer from 1 to 100. I will try to guess ");
    printf("it.\nRespond with a y if my guess is right and with");
    printf("\nan n if it is wrong.\n");
    printf("Uh...is your number %d?\n", guess);
    while ((response = getchar()) != 'y')      // get response, compare to y
    {
        // Don't treat  something like `f`  as `n`.  Screen out  responses other
        // than `y` and `n`.
        if (response != 'n')
            printf("Sorry, I only understand y or n.\n");
        else
            printf("Well, then, is it %d?\n", ++guess);

        // We need to  skip the rest of  the input line to  prevent the previous
        // `getchar()` from wrongly interpreting some characters as answers:
        //
        //     no sir\n
        //      ^-----^
        //      skip over all of that
        //
        // Note that even if you just type `n`, you still write a newline in the
        // input buffer (by pressing Enter) which the previous `getchar()` would
        // wrongly pick up if you didn't skip input until `\n`.
        while (getchar() != '\n')
            continue;
    }
    printf("I knew I could do it!\n");

    return 0;
}
