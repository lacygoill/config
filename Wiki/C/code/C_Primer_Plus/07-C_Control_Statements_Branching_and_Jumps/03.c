// Purpose: alters input, preserving non-letters
// Reference: page 246 (paper) / 275 (ebook)

#include <stdio.h>
#include <ctype.h>

    int
main(void)
{
    int ch;

    while ((ch = getchar()) != '\n')
    {
        if (isalpha(ch))      // if a letter,
            putchar(ch + 1);  // display next letter
        else                  // otherwise
            putchar(ch);      // display as is
    }
    putchar(ch);              // display the new line

    return 0;
}
