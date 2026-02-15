// Purpose: use the logical AND operator
// Reference: page 263 (paper) / 292 (ebook)

#include <stdio.h>
#define PERIOD '.'

    int
main(void)
{
    int ch;
    int charcount = 0;

    while ((ch = getchar()) != PERIOD)
    {
        if (ch != '\'' && ch != '"')
            charcount++;
    }
    printf("There are %d non-quote characters.\n", charcount);

    return 0;
}
