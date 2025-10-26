// Purpose: Write a program to count blanks, tabs, and newlines.
// Reference: page 20 (paper) / 34 (ebook)

#include <stdio.h>

    int
main(void)
{
    int c, nb, nt, nl;

    nb = nt = nl = 0;

    while ((c = getchar()) != EOF)
    {
        if (c == ' ')
            ++nb;
        if (c == 't')
            ++nt;
        if (c == '\n')
            ++nl;
    }

    printf("blanks: %d, tabs: %d, newlines: %d", nb, nt, nl);
}
