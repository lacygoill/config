// Purpose: Write  a program  that reads  input until  encountering #.  Have the
// program print each  input character and its ASCII decimal  code.  Print eight
// character-code pairs  per line.   Suggestion: Use a  character count  and the
// modulus operator (%)  to print a newline character for  every eight cycles of
// the loop.
//
// Reference: page 296 (paper) / 325 (ebook)

#include <stdio.h>
#define CHARS_PER_LINE 8

    int
main(void)
{
    int ch;
    int cnt = 0;
    printf("Enter some characters(# to quit):\n");
    while ((ch = getchar()) != '#')
    {
        if ((cnt % CHARS_PER_LINE) == 0)
            putchar('\n');
        printf("%c:%hhu ", ch, ch);
        ++cnt;
    }

    return 0;
}
