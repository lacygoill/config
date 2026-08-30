// Purpose: prints a string without adding `\n` using array notation
// Reference: page 467 (paper) / 496 (ebook)

#include <stdio.h>

void put1(const char * string);

    int
main(void)
{
    put1("Hello");
    return 0;
}
//     Hello⏎

    void
put1(const char * string)
{
    int i = 0;
    while (string[i] != '\0')
        putchar(string[i++]);
}
