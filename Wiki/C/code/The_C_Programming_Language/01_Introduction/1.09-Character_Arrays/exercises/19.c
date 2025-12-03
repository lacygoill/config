// Purpose: Write a function `reverse(s)` that reverses the character string `s`.
// Use it to write a program that reverses its input a line at a time.
//
// Reference: page 31 (paper) / 45 (ebook)

#include <stdio.h>
#define MAXLINE 1000

int get_line(char line[]);
void reverse(char line[]);

    int
main(void)
{
    char line[MAXLINE];

    int len;
    while ((len = get_line(line)) > 0)
    {
        reverse(line);
        printf("%s", line);
    }

    return 0;
}

    int
get_line(char s[])
{
    int i, c;
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

    void
reverse(char s[])
{
    int i, j;
    char temp;
    i = j = 0;

    // find the end of the string
    while (s[j] != '\0')
        ++j;

    // back off, so that `\0` isn't reversed in 1st position
    --j;

    // the newline must remain at the end too
    if (s[j] == '\n')
        --j;

    // Now `j`  is on the  last character  of the string,  and `i` on  the first
    // one.  Let's make `j` iterate over the characters from the end down to the
    // middle  of  the string.   Similarly,  let's  make  `i` iterate  over  the
    // characters from the start of the string up to the middle.
    while (i < j)
    {
        temp = s[i];
        s[i] = s[j];
        s[j] = temp;
        ++i;
        --j;
    }
}
