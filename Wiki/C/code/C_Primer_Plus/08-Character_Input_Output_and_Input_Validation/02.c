// Purpose: repeats input to end of file
// Reference: page 305 (paper) / 334 (ebook)

#include <stdio.h>

    int
main(void)
{
    int ch;

    while ((ch = getchar()) != EOF)
        putchar(ch);

    return 0;
}
