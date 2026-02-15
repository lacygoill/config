// Purpose: In question  2c, what changes could  you make so that  string `Q` is
// printed out enclosed in double quotation marks?
//
// Reference: page 138 (paper) / 167 (ebook)

#include <stdio.h>
#include <string.h>

    int
main(void)
{
    #define Q "His Hamlet was funny without being vulgar."
    printf("\"%s\"\nhas %zd characters.\n", Q, strlen(Q));
    //      ^^  ^^
    return 0;
}
