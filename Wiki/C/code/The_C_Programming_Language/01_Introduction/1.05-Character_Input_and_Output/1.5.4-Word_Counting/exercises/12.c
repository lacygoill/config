// Purpose: Write a program that prints its input one word per line.
// Reference: page 21 (paper) / 35 (ebook)

#include <stdio.h>

#define OUT 0
#define IN 1

    int
main(void)
{
    int c, state;

    state = OUT;

    while ((c = getchar()) != EOF)
    {
        if (c == ' ' || c == '\t' || c == '\n')
        {
            // end of a word
            if (state == IN)
            {
                putchar('\n');
                state = OUT;
            }
        }
        // start of a word
        else if (state == OUT)
        {
            state = IN;
            putchar(c);
        }
        // middle of a word
        else
            putchar(c);
    }

    return 0;
}
