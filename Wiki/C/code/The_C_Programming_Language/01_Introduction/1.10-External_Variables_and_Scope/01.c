// Purpose: Rewrite the longest-line program with `line`, `longest` and `max` as
// external variables.
// Reference: page 31 (paper) / 45 (ebook)

#include <stdio.h>

#define MAXLINE 1000

char line[MAXLINE];
char longest[MAXLINE];

int get_line(void);
void copy(void);

// print longest input line, specialized version
    int
main(void)
{
    int len;
    int max = 0;
    // --v
    extern char longest[];

    while ((len = get_line()) > 0)
        if (len > max)
        {
            max = len;
            copy();
        }
    if (max > 0)
        printf("%s", longest);
    return 0;
}

// get_line: specialized version
    int
get_line(void)
{
    int c, i;
    // --v
    extern char line[];

    for (i = 0; i < MAXLINE - 1 && (c = getchar()) != EOF && c != '\n'; ++i)
        line[i] = (char)c;
    if (c == '\n')
    {
        line[i] = (char)c;
        ++i;
    }
    line[i] = '\0';
    return i;
}

// copy: specialized version
    void
copy(void)
{
    int i;
    // --v
    extern char line[], longest[];

    i = 0;
    while ((longest[i] = line[i]) != '\0')
        ++i;
}
