// Purpose: Suppose that `ch` is a type `char` variable.  Show how to assign the
// carriage-return character to `ch` using  an escape sequence, a decimal value,
// an octal character constant, and a hex character constant. (Assume ASCII code
// values)
//
// Reference: page 96 (paper) / 125 (ebook)

#include <stdio.h>

    int
main(void)
{
    char ch;

    ch = '\r';
    ch = 13;
    ch = '\015';
    ch = '\x0D';

    printf("%c", ch);

    return 0;
}
