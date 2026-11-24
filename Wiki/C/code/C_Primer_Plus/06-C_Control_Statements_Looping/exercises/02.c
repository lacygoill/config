// Purpose: Use nested loops to produce the following pattern:
//
//     $
//     $$
//     $$$
//     $$$$
//     $$$$$
//
// Reference: page 241 (paper) / 270 (ebook)

#include <stdio.h>

    int
main(void)
{
    for (int row = 1; row <= 5; row++)
    {
        for (int col = 1; col <= row; col++)
            printf("$");
        printf("\n");
    }

    return 0;
}
