// Purpose: Experiment  to  find out  what  happens  when `printf()`'s  argument
// string contains `\c` where `c` is some character not listed above.
// Reference: page 8 (paper) / 22 (ebook)

#include <stdio.h>

// The following results depend on the compiler.

    int
main(void)
{
    //                  vv
    printf("hello, world\y\n");
    //     warning: unknown escape sequence: '\y'
    //     output: hello, worldy
    //                         ^

    //                  vv
    printf("hello, world\7\n");
    //     output: hello, world^G
    //                         ^^
    //                         BELL character
    //                         (visible if you pipe the output to `od(1)`)

    //                  vv
    printf("hello, world\?\n");
    //     output: hello, world?
    //                         ^
    return 0;
}
