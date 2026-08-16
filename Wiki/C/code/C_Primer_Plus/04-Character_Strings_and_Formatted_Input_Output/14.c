// Purpose: printing long strings
// Reference: page 127 (paper) / 156 (ebook)

#include <stdio.h>

    int
main(void)
{
    // use multiple `printf()`
    printf("Here's one way to print a");
    printf("long string.\n");

    // embed a newline with a trailing backslash
    printf("Here's another way to print a \
long string.\n");

    // use string concatenation
    printf("Here's the newest way to print a "
            "long string.\n");

    return 0;
}
