// Purpose: Redo exercise 4 using a `switch`.
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
        switch (ch)
        {
            case '.': putchar('!');
                      ++n_subs;
                      break;
            case '!': putchar('!');
                      putchar('!');
                      ++n_subs;
                      break;
            default: putchar(ch);
        }
    }
    printf("\nThere are %d substitutions.\n", n_subs);

    return 0;
}
