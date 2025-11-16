// Purpose: Write a program copying its input  to its output, replacing each tab
// by `\t`, each backspace by `\b`, and each backslash by `\\`.
// Reference: page 20 (paper) / 34 (ebook)

#include <stdio.h>

    int
main(void)
{
    int c;

    while ((c = getchar()) != EOF)
        if (c == '\t')
            printf("\\t");
        else if (c == '\b')
            printf("\\b");
        else if (c == '\\')
            printf("\\\\");
        else
            putchar(c);
}
