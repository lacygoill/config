// Purpose: alters input, preserving spaces
// Reference: page 246 (paper) / 275 (ebook)

#include <stdio.h>
#define SPACE ' '

    int
main(void)
{
    int ch;

    ch = getchar();           // read a character
    while (ch != '\n')        // while not end of line
    {
        if (ch == SPACE)      // leave the space
            putchar(ch);
        else
            putchar(ch + 1);  // change other characters
        ch = getchar();      // get next character
    }
    putchar(ch);              // print newline

    return 0;
}
