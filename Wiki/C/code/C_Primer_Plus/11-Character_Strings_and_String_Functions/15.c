// Purpose: prints a string and count characters
// Reference: page 468 (paper) / 497 (ebook)

#include <stdio.h>

int put2(const char* string);

    int
main(void)
{
    printf("The string contains %d characters.\n", put2("Hello"));
    return 0;
}

int put2(const char* string)
{
    int count = 0;
    while (*string)
    {
        putchar(*string++);
        count++;
    }
    putchar('\n');

    return count;
}

//     Hello
//     The string contains 5 characters.
