// Purpose: Rewrite the  program in Review  Question 9  so that it  exhibits the
// same behavior but does not use a `continue` or a `goto`.
//
// Reference: page 295 (paper) / 324 (ebook)

#include <stdio.h>
    int
main(void)
{
    int ch;

    while ((ch = getchar()) != '#')
    {
        if (ch != '\n')
        {
            printf("Step 1\n");
            if (ch != 'c')
            {
                if (ch == 'b')
                    break;
                else if (ch == 'h')
                    printf("Step 3\n");
                else
                {
                    printf("Step 2\n");
                    printf("Step 3\n");
                }
            }
        }
    }
    printf("Done\n");
    return 0;
}
