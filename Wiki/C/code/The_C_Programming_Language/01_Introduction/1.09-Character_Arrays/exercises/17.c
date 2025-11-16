// Purpose: Write a program to print all input lines that are longer than 80 characters.
// Reference: page 31 (paper) / 45 (ebook)

#include <stdio.h>

#define MAXLINE 1000
#define LONGLINE 80

int get_line(char s[]);

    int
main(void)
{
    int len;
    char line[MAXLINE];

    while ((len = get_line(line)) > 0)
        if (len > LONGLINE)
            printf("%s", line);
}

    int
get_line(char s[])
{
    int c, i;
    for (i = 0; i < MAXLINE - 1 && (c = getchar()) != EOF && c != '\n'; ++i)
        s[i] = (char)c;

    if (c == '\n')
    {
        s[i] = (char)c;
        ++i;
    }

    s[i] = '\0';

    return i;
}
