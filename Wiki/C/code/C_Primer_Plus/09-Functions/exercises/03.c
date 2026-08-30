// Purpose: Write a  function that  takes three arguments:  a character  and two
// integers.  The character  is to be printed.  The first  integer specifies the
// number of times that the character is to be printed on a line, and the second
// integer  specifies the  number of  lines  that are  to be  printed.  Write  a
// program that makes use of this function.
//
// Reference: page 380 (paper) / 409 (ebook)

#include <stdio.h>

void putchars(char ch, int cols, int lines);

    int
main(void)
{
    char ch;
    int cols, lines;
    printf("Enter the character you want to print: ");
    ch = (char)getchar();
    printf("Enter how many times and on how many lines the character is to be printed: ");
    scanf("%d%d", &cols, &lines);
    putchars(ch, cols, lines);
}

    void
putchars(char ch, int cols, int lines)
{
    for (int i = 1; i <= lines; i++)
    {
        for (int j = 1; j <= cols; j++)
            putchar(ch);
        putchar('\n');
    }
}
