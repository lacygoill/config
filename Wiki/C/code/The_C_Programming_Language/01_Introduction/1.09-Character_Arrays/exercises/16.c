// Purpose: Revise  the main  routine of  the  longest-line program  so it  will
// correctly print  the length of arbitrarily  long input lines, and  as much as
// possible of the text.
//
// In  the original  code, if  a line  was longer  than `MAXLINE`,  `get_line()`
// returned the latter.  Now,  it should return the true length  of a line, even
// if it's  longer than `MAXLINE`.   It should still stop  collecting characters
// beyond `MAXLINE` though.
//
// Reference: page 30 (paper) / 44 (ebook)

#include <stdio.h>

#define MAXLINE 1000

int get_line(char line[]);

void copy(char from[], char to[]);

    int
main(void)
{
    int len;
    int max;

    char line[MAXLINE];
    char longest[MAXLINE];

    max = 0;
    while ((len = get_line(line)) > 0)
        if (len > max)
        {
            max = len;
            copy(line, longest);
        }
    if (max > 0)
        printf("%d, %s", max, longest);
    return 0;
}

    int
get_line(char s[])
{
    int c, i, j;

    // We need  an extra  index.  Now,  at the  end, `i`  should index  the last
    // character of the  line, even if it's  too long for `MAXLINE`,  so that we
    // can report the true length a long line to `main()`.
    //
    // But we also need an index to know where to append `\n` and `\0`.
    // That's the purpose of `j`.
    j = 0;
    for (i = 0; (c = getchar()) != EOF && c != '\n'; ++i)
    {
        // This time, `c` *can* be set to `\n` during the iteration where `i` is
        // `MAXLINE - 1`, because the `i <` check occurs after `c != '\n'`.  So,
        // the condition needs to be stricter (`< MAXLINE - 2`).
        if (i < MAXLINE - 2)
        {
            s[j] = (char)c;
            ++j;
        }
    }
    if (c == '\n')
    {
        s[j] = (char)c;
        ++j;
        ++i;
    }
    s[j] = '\0';
    return i;
}

    void
copy(char from[], char to[])
{
    int i = 0;
    while ((to[i] = from[i]) != '\0')
        ++i;
}
