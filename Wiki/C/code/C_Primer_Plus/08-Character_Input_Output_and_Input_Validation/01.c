// Purpose: repeats input
// Reference: page 300 (paper) / 329 (ebook)

#include <stdio.h>

    int
main(void)
{
    int ch;
    while ((ch = getchar()) != '#')
    {
        putchar(ch);
    }

    return 0;
}
