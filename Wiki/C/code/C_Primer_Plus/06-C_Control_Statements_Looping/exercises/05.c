// Purpose: Have a program  request the user to enter an  uppercase letter.  Use
// nested loops to produce a pyramid pattern like this:
//
//         A
//        ABA
//       ABCBA
//      ABCDCBA
//     ABCDEDCBA
//
// The  pattern  should extend  to  the  character  entered.  For  example,  the
// preceding pattern would result from an  input value of E.  Hint: Use an outer
// loop to handle the  rows.  Use three inner loops in a row,  one to handle the
// spaces, one  for printing letters  in ascending  order, and one  for printing
// letters in descending  order.  If your system doesn't use  ASCII or a similar
// system that represents letters in strict  number order, see the suggestion in
// programming exercise 3.
//
// GCC Options: -Wno-strict-overflow
//
// Reference: page 242 (paper) / 271 (ebook)

#include <stdio.h>

    int
main(void)
{
    char ch;
    char uppercase_letter;
    int row;
    int last_row;

    printf("Enter an uppercase letter: ");
    scanf("%c", &uppercase_letter);

    last_row = uppercase_letter - 'A' + 1;
    for (row = 1; row <= last_row; row++)
    {
        // print leading spaces
        for (int i = 1; i <= last_row - row; i++)
            printf(" ");

        // print letters in ascending order (excluding the middle one)
        for (ch = 'A'; ch <= 'A' + row - 2; ch++)
            printf("%c", ch);

        // print letters in descending order (including the middle one)
        for (; ch >= 'A'; ch--)
            printf("%c", ch);

        printf("\n");
    }

    return 0;
}
