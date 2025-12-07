// Purpose: Change `long`  to `unsigned long`  and try to  find the  number that
// makes it too big.
// Reference: page 56

#include <stdio.h>

    int
main(void)
{
    // According to `/usr/include/limits.h`, this is the biggest integer that an
    // `unsigned long` variable can hold:
    unsigned long universe_of_defects = 18446744073709551615UL;
    //                                                      ^^
    // Beyond, for example if you add 1, you get 0.
    printf("%lu\n", universe_of_defects);
    //       ^^
    //       `l` is a length modifier, while `u` is a conversion specification
    //       (it converts an `unsigned int` into an unsigned decimal notation);
    //       a length modifier comes *before* a conversion specification

    return 0;
}
