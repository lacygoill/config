// Purpose: Write a program to remove trailing blanks and tabs from each line of
// input, and to delete entirely blank lines.
//
// GCC Options: -Wno-strict-overflow
//
// Reference: page 31 (paper) / 45 (ebook)

#include <stdio.h>
#define MAXLINE 1000

int trim(char line[]);
int get_line(char line[]);

    int
main(void)
{
    int len;
    char line[MAXLINE];
    while ((len = get_line(line)) > 0)
    {
        if (trim(line) > 0)
            printf("%s", line);
    }
    return 0;
}

    int
get_line(char s[])
{
    int c;
    int i = 0;
    for (i = 0; (i < MAXLINE - 1) && (c = getchar()) != EOF && c != '\n'; ++i)
        s[i] = (char)c;
    if (c == '\n')
    {
        s[i] = (char)c;
        ++i;
    }
    s[i] = '\0';
    return i;
}

    int
trim(char s[])
{
    int i = 0;
    // look for the newline
    while (s[i] != '\n')
        ++i;

    // get back to character before
    --i;

    // look for the last non-whitespace
    while (i >= 0 && (s[i] == ' ' || s[i] == '\t'))
        --i;

    // only if the line is not empty
    if (i >= 0)
    {
        // we don't want to trim the last non-whitespace
        ++i;

        // put back the newline
        s[i] = '\n';

        // trim everything after
        ++i;
        s[i] = '\0';
    }

    return i;
}
