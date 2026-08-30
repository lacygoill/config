// Purpose: Use nested loops to write a program that produces this pattern:
//
//     $$$$$$$$
//     $$$$$$$$
//     $$$$$$$$
//     $$$$$$$$
//
// Reference: page 237 (paper) / 266 (ebook)

#include <stdio.h>
#define ROWS 4
#define COLUMNS 8

    int
main(void)
{
    for (int i = 1; i <= ROWS; i++)
    {
        for (int j = 1; j <= COLUMNS; j++)
            printf("$");
        printf("\n");
    }
    return 0;
}
