// Purpose: Write  a program  copying its  input to  its output,  replacing each
// string of one or more blanks by a single blank.
// Reference: page 20 (paper) / 34 (ebook)

#include <stdio.h>

    int
main(void)
{
    int c, prev;

    // It  doesn't  matter how  we  initialize  `prev`.   It  just needs  to  be
    // different than  `' '` so that  our program outputs  a space if  our input
    // starts with a space.
    prev = EOF;

    while ((c = getchar()) != EOF)
    {
        if (c != ' ' || prev != ' ')
            putchar(c);

        prev = c;
    }
}
