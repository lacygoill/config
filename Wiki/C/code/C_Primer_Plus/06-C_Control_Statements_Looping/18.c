// Purpose: use dependent nested loops
// Reference: page 226 (paper) / 255 (ebook)

#include <stdio.h>
#define ROWS 6
#define CHARS 6

    int
main(void)
{
    int row;
    char ch;

    for (row = 0; row < ROWS; row++)
    {
        for (ch = ('A' + (char)row); ch < ('A' + CHARS); ch++)
            printf("%c", ch);
        printf("\n");
    }
    //     ABCDEF
    //     BCDEF
    //     CDEF
    //     DEF
    //     EF
    //     F

    return 0;
}
