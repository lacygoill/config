// Purpose: Use nested loops to produce the following pattern:
//
//     A
//     BC
//     DEF
//     GHIJ
//     KLMNO
//     PQRSTU
//
// If your system doesn't encode letters  in numeric order, see the suggestion
// in programming exercise 3.
//
// Reference: page 241 (paper) / 270 (ebook)

#include <stdio.h>

    int
main(void)
{
    char ch = 'A';
    int j = 0;
    for (int row = 1; row <= 6; row++)
    {
        for (int i = 1; i <= row; i++)
        {
            printf("%c", ch + j);
            ++j;
        }
        printf("\n");
    }
    return 0;
}
