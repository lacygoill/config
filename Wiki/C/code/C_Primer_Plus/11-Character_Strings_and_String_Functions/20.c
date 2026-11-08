// Purpose: will this work?
// GCC Options: -Wno-address
// Reference: page 475 (paper) / 504 (ebook)

#include <stdio.h>
#include <stdlib.h>
#define ANSWER "Grant"
#define SIZE 40
char * s_gets(char * st, int n);

    int
main(void)
{
    char try[SIZE];

    puts("Who is buried in Grant's tomb?");
    s_gets(try, SIZE);
    // This will not work as expected.   `ANSWER` and `try` are pointers, so the
    // comparison `try != ANSWER` doesn't  check to see whether  the two strings
    // are the same.  Rather, it checks to  see whether the two strings have the
    // same  address.   Because  `ANSWER`  and `try`  are  stored  in  different
    // locations, the two addresses are never  the same, and the user is forever
    // told that he or she is wrong.
    //
    // ---
    //
    // `*try != *ANSWER` wouldn't be correct  either. `*try` and `*ANSWER` would
    // evaluate to their respective first character.
    while (try != ANSWER)
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
