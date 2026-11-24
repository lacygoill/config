// Purpose: Using if else statements, write a  program that reads input up to #,
// replaces each period with an exclamation mark, replaces each exclamation mark
// initially present  with two  exclamation marks,  and reports  at the  end the
// number of substitutions it has made.
//
// Reference: page 296 (paper) / 325 (ebook)

#include <stdio.h>

    int
main(void)
{
    int ch;
    int n_subs = 0;

    printf("Enter some texts(# to quit):\n");
    while ((ch = getchar()) != '#')
    {
        if (ch == '.')
        {
            putchar('!');
            ++n_subs;
        }
        else if (ch == '!')
        {
            putchar('!');
            putchar('!');
            ++n_subs;
        }
        else
            putchar(ch);
    }
    printf("\nThere are %d substitutions.\n", n_subs);

    return 0;
}
