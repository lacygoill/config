// Purpose: will this work?
// Reference: page 475 (paper) / 504 (ebook)

#include <stdio.h>
#include <string.h>

#define ANSWER "Grant"
#define SIZE 40
char * s_gets(char * st, int n);

    int
main(void)
{
    char try[SIZE];

    puts("Who is buried in Grant's tomb?");
    s_gets(try, SIZE);
    // What you  need is a  function that  compares string contents,  not string
    // addresses.  `strcmp()`  (for string  comparison)  does  for strings  what
    // relational operators  do for numbers.   In particular, it returns  `0` if
    // its two string arguments are the same and nonzero otherwise.
    //     v----v
    while (strcmp(try, ANSWER))    // short for `strcmp(try, ANSWER) != 0`
    {
        puts("No, that's wrong.  Try again.");
        // terminate on EOF
        if (!s_gets(try, SIZE))
            return 0;
    }
    puts("That's right!");

    return 0;
}

    char *
s_gets(char * st, int n)
{
    char * ret_val;
    int i = 0;

    ret_val = fgets(st, n, stdin);
    if (ret_val)
    {
        while (st[i] != '\n' && st[i] != '\0')
            i++;
        if (st[i] == '\n')
            st[i] = '\0';
        else
            while (getchar())
                continue;
    }
    return ret_val;
}
