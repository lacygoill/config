// Purpose: finding `printf()`'s return value
// Reference: page 126 (paper) / 155 (ebook)

#include <stdio.h>

    int
main(void)
{
    int bph2o = 212;
    int rv;

    rv = printf("%d F is water's boiling point.\n", bph2o);
    printf("The printf() function printed %d characters.\n", rv);
    //     212 F is water's boiling point.
    //     The printf() function printed 32 characters.
    //                                   ^^
    //                                   includes the trailing newline

    return 0;
}
