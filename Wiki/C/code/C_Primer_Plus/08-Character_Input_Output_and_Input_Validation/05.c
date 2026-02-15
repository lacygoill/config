// Purpose: program with a BIG I/O problem
// Reference: page 315 (paper) / 344 (ebook)

#include <stdio.h>

void display(char cr, int lines, int width);

    int
main(void)
{
    int ch;             // character to be printed
    int rows, cols;     // number of rows and columns
    printf("Enter a character and two integers:\n");
    // This loop is actually broken.  It will iterate only once because we don't
    // flush the input which contains a newline.
    while ((ch = getchar()) != '\n')
    //                      ^-----^
    //                      we want to stop when the user presses a newline at
    //                      the start of a line
    {
        scanf("%d %d", &rows, &cols);
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
