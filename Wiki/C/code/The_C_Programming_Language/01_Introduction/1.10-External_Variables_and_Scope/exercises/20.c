// Purpose: Write a  program `detab` that  replaces tabs  in the input  with the
// proper number of blanks to space to the next tab stop.  Assume a fixed set of
// tab stops,  say every `n`  columns.  Should `n` be  a variable or  a symbolic
// parameter?
//
// Reference: page 34 (paper) / 48 (ebook)

#include <stdio.h>
#define TABSTOP 8

    int
main(void)
{
    int c, pos, spaces;
    pos = 1;
    while ((c = getchar()) != EOF)
        if (c == '\n')
        {
            putchar('\n');
            pos = 1;
        }
        else if (c == '\t')
        {
            spaces = TABSTOP - (pos - 1) % TABSTOP;
            while (spaces > 0)
            {
                putchar(' ');
                --spaces;
                ++pos;
            }
        }
        else
        {
            putchar(c);
            ++pos;
        }
}
