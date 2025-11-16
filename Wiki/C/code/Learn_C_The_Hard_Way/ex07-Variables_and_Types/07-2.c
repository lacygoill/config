// Purpose: Check out what happens when we assign after the end of a string.
// Reference: page 54

#include <stdio.h>

    int
main(void)
{
    char str[] = "hell";
    str[4] = 'o';
    // Most often, this should print gibberish after `hello`:
    //
    //     hello8+k
    //          ^^^
    //
    // That's because we assigned `o` where a NUL was before:
    //
    //     hell\0
    //     ^----^
    //     01234
    //
    // and  `printf()` writes  up to  a  NUL.  If  you  erase the  NUL, it  will
    // continue writing until it finds a NUL god knows where.
    printf("%s", str);
    return 0;
}
