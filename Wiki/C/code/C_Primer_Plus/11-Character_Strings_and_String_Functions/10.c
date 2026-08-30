// Purpose: Read a  whole line  and replace  the newline  character with  a null
// character, or read the part of a line that fits and discard the rest.
//
// Reference: page 461 (paper) / 490 (ebook)

#include <stdio.h>
char * s_gets(char * st, int n);

    int
main(void)
{
    return 0;
}

    char *
s_gets(char * st, int n)
{
    char * ret_val;
    int i = 0;

    ret_val = fgets(st, n, stdin);
    if (ret_val)  // short for `ret_val != NULL`
    {
        while (st[i] != '\n' && st[i] != '\0')
            i++;
        // replace newline with null character
        if (st[i] == '\n')
            st[i] = '\0';
        // discard rest of line
        else // must have `st[i] == '\0'`
            while (getchar() != '\n')
                continue;
    }
    return ret_val;
}
