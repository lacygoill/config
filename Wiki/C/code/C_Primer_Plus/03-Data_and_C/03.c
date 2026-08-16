// Purpose: prints 100 in decimal, octal, and hex
// Reference: page 66 (paper) / 95 (ebook)

#include <stdio.h>

    int
main(void)
{
    int x = 100;

    printf("dec = %d; octal = %o; hex = %x\n", x, x, x);
    printf("dec = %d; octal = %#o; hex = %#x\n", x, x, x);
    //                         ^          ^
    //                         add the 0x (hex) or 0 (octal) prefix

    return 0;
}
