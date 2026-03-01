// Purpose: Modify the  `get_first()` function of  Listing 8.8 so that  it returns
// the first nonwhitespace character encountered.  Test it in a simple program.
//
// Reference: page 333 (paper) / 362 (ebook)

#include <stdio.h>
#include <ctype.h>

char get_first(void);

    int
main(void)
{
    char ch;
    while ((ch = get_first()) != EOF)
    {
        putchar(ch);
        putchar('\n');
    }

    return 0;
}

    char
get_first(void)
{
    int ch;

    while ((ch = getchar()) != '\n' && isspace(ch))
        continue;

    return (char)ch;
}
