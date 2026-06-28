// Purpose: prints a string without adding `\n`
// Reference: page 467 (paper) / 496 (ebook)

#include <stdio.h>

void put1(const char * string);   // string not altered

    int
main(void)
{
    put1("Hello");
    return 0;
}
//     Hello⏎
//
// Notice how our `put1()` didn't add an extra newline, contrary to `puts()`.

    void
put1(const char * string)
{
    // Short for `*string != '\0'`.  When `string` points to the null character,
    // `*string` has the  value 0 (which is the same  as `\0`), which terminates
    // the loop.
    while (*string)
        putchar(*string++);
}
