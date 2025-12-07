// Purpose: Write a program to print a histogram of the frequencies of different characters in its input.{{{
//
// Output example:
//
//     ...
//     114 - r - 58830 : ********
//     115 - s - 93996 : *************
//     116 - t - 53699 : *******
//     117 - u - 27006 : ***
//     118 - v - 8000 : *
//     119 - w - 7386 : *
//     120 - x - 2252 : *
//     121 - y - 12985 : *
//     122 - z - 3304 : *
//     123 - { - 0 :
//     124 - | - 0 :
//     125 - } - 0 :
//     126 - ~ - 0 :
//     127 -    - 0 :
//}}}
// Reference: page 22 (paper) / 36 (ebook)

#include <ctype.h>
#include <stdio.h>

#define MAXHBAR 15    // maximum height of a bar in the histogram
#define MAXCHAR 128   // maximum different characters

    int
main(void)
{
    int c, i;
    int maxc;           // bigger count in the histogram
    int blen;           // length of a bar in the histogram
    int cc[MAXCHAR];    // array of counts for word frequencies

    for (i = 0; i < MAXCHAR; ++i)
        cc[i] = 0;

    while ((c = getchar()) != EOF)
        if (c < MAXCHAR)
            ++cc[c];

    maxc = 0;
    for (i = 1; i < MAXCHAR; ++i)
        if (cc[i] > maxc)
            maxc = cc[i];

    for (i = 1; i < MAXCHAR; ++i)
    {
        if (isprint(i))
            //           convert `i` into a character (like `nr2char()` in Vimscript)
            //           vv
            printf("%d - %c - %d : ", i, i, cc[i]);
        else
            printf("%d -    - %d : ", i, cc[i]);
        if (cc[i] == 0)
            blen = 0;
        else if ((blen = MAXHBAR * cc[i] / maxc) == 0)
                blen = 1;
        while (blen > 0)
        {
            putchar('*');
            --blen;
        }
        putchar('\n');
    }

    return 0;
}
