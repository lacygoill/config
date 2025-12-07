// Purpose: Use more conversion specifications in `printf()`.
// Reference: page 13 (paper) / 27 (ebook)

#include <stdio.h>

    int
main(void)
{
    int num = 123;
    char ch = 'A';
    char str[] = "Hello, world!";

    // `%o`
    printf("%o\n", num);
    //     173

    // `%x`
    printf("%x\n", num);
    //     7b

    // `%c`
    printf("%c\n", ch);
    //     A

    // `%s`
    printf("%s\n", str);
    //     Hello, world!

    return 0;
}
