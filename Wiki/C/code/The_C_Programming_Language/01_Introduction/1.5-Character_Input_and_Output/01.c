// Purpose: Study `getchar()` and `putchar()`.
// Reference: page 15 (paper) / 29 (ebook)

#include <stdio.h>

    int
main(void)
{
    // `getchar()` returns an `int`, so we need to declare `c` as an `int` too
    int c;

    // `getchar()` reads the next input character from the keyboard, and returns
    // that as its value
    c = getchar();

    // `putchar()` prints the contents of `c` as a character on the screen
    putchar(c);

    return 0;
}
