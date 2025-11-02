// Purpose: Write a program which copies its input to its output one character at a time.
// Reference: page 16 (paper) / 30 (ebook)

#include <stdio.h>

    int
main(void)
{
    int c;

    c = getchar();
    //       relational operator meaning "not equal to"
    //       |  integer defined in `stdio.h`;
    //       |  its value is defined in such a way that it's different than any `char` value
    //       vv vvv
    while (c != EOF) {
        putchar(c);
        c = getchar();
    }

    return 0;
}
