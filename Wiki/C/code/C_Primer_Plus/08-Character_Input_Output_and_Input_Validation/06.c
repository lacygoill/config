// Purpose: prints characters in rows and columns
// Reference: page 316 (paper) / 345 (ebook)

#include <stdio.h>

void display(char cr, int lines, int width);

    int
main(void)
{
    int ch;             // character to be printed
    int rows, cols;     // number of rows and columns
    printf("Enter a character and two integers:\n");
    while ((ch = getchar()) != '\n')
    {
        // terminate  if  one or  both  input  values  are  not integers  or  if
        // end-of-file is encountered.
        if (scanf("%d %d", &rows, &cols) != 2)
            break;
        // flush the input so that the outer loop iterates more than once
        while (getchar() != '\n')
            continue;
        display((char)ch, rows, cols);
        printf("Enter another character and two integers;\n");
        printf("Enter a newline to quit.\n");
    }
    printf("Bye.\n");

    return 0;
}

    void
display(char cr, int lines, int width)
{
    int row, col;
    for (row = 1; row <= lines; row++)
    {
        for (col = 1; col <= width; col++)
            putchar(cr);
        putchar('\n');  // end line and start a new one
    }
}
