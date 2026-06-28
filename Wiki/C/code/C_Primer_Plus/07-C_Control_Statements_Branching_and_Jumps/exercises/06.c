// Purpose: Write a program that  reads input up to # and  reports the number of
// times that the sequence `ei` occurs.
//
// Reference: page 296 (paper) / 325 (ebook)

#include <stdio.h>

    int
main(void)
{
    int ch;
    int prev = 0;
    int n_seq = 0;

    printf("Enter some texts(# to quit):\n");
    while ((ch = getchar()) != '#')
    {
        if (prev == 'e' && ch == 'i')
            ++n_seq;
        prev = ch;
    }
    printf("The sequence ei appears %d times.\n", n_seq);

    return 0;
}
