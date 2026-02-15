// Purpose: use nested loops
// Reference: page 224 (paper) / 253 (ebook)

#include <stdio.h>
#define ROWS 6
#define CHARS 10

    int
main(void)
{
    int row;
    char ch;

    for (row = 0; row < ROWS; row++)
    {
        for (ch = 'A'; ch < ('A' + CHARS); ch++)
            printf("%c", ch);
        printf("\n");
    }
    //     ABCDEFGHIJ
    //     ABCDEFGHIJ
    //     ABCDEFGHIJ
    //     ABCDEFGHIJ
    //     ABCDEFGHIJ
    //     ABCDEFGHIJ

    return 0;
}
