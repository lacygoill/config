// Purpose: Write a program that reads  input until encountering the # character
// and then reports the number of  spaces read, the number of newline characters
// read, and the number of all other characters read.
//
// Reference: page 296 (paper) / 325 (ebook)

#include <stdio.h>

    int
main(void)
{
    int ch;
    int n_spaces = 0;
    int n_newlines = 0;
    int n_other = 0;

    printf("Enter some text; Enter # to quit.\n");
    while ((ch = getchar()) != '#')
    {
        if (ch == ' ')
            ++n_spaces;
        else if (ch == '\n')
            ++n_newlines;
        else
            ++n_other;
    }
    printf("There are %d spaces, %d newlines, and %d other characters.\n",
            n_spaces, n_newlines, n_other);

    return 0;
}
