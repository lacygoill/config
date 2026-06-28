// Purpose: Use nested loops to produce the following pattern:
//
//     F
//     FE
//     FED
//     FEDC
//     FEDCB
//     FEDCBA
//
// Note: If  your system  doesn't  use ASCII  or some  other  code that  encodes
// letters in numeric order, you can use the following to initialize a character
// array to the letters of the alphabet:
//
//     char lets[27] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
//
// Then you can  use the array index to select  individual letters; for example,
// `lets[0]` is 'A', and so on.
//
// Reference: page 241 (paper) / 270 (ebook)

#include <stdio.h>

    int
main(void)
{
    for (int row = 1; row <= 6; row++)
    {
        for (char ch = 'F'; ch >= 'F' - row + 1; ch--)
            printf("%c", ch);
        printf("\n");
    }
    return 0;
}
