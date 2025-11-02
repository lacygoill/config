// Purpose: Rewrite the previous program so that it prints the histogram with a vertical orientation.{{{
//
// Output example:
//
//                                                         *
//                                                  *      *
//                                                  *      *      *
//                                                  *      *      *
//                                                  *      *      *      *
//                                           *      *      *      *      *
//                                           *      *      *      *      *
//                                           *      *      *      *      *
//                                           *      *      *      *      *
//                                    *      *      *      *      *      *
//                                    *      *      *      *      *      *
//                                    *      *      *      *      *      *
//                             *      *      *      *      *      *      *
//                             *      *      *      *      *      *      *
//        *      *      *      *      *      *      *      *      *      *
//          1      2      3      4      5      6      7      8      9     10
//         52    373   1165   3569   7033  11732  15457  16433  15037  12115
//     There are 21368 words >= 11
//}}}
// Reference: page 24 (paper) / 38 (ebook)

#include <stdio.h>

// for `state`
#define IN 1
#define OUT 0

#define MAXWLEN 11    // maximum length of a word appearing in the histogram
#define MAXHBAR 15    // maximum height of a bar in the histogram

    int
main(void)
{
    int c, i, j;
    int nc;             // number of characters in a word
    int state;          // flag: are we inside a word or not?
    int overflow;       // number of words longer than `MAXWLEN`
    int maxc;           // bigger count in the histogram
    int wc[MAXWLEN];    // array of counts for word lengths

    // initialize variables; don't forget to initialize `wc`'s members
    state = OUT;
    nc = overflow = 0;
    for (i = 1; i < MAXWLEN; ++i)
        wc[i] = 0;

    // Compute the counts for each word length below `MAXWLEN`.
    // Save the counts in the `wc` array.
    while ((c = getchar()) != EOF)
        if (c == ' ' || c == '\t' || c == '\n')
        {
            // at the end of a word
            if (state == IN)
            {
                // the word is too big for the histogram
                if (nc >= MAXWLEN)
                    ++overflow;
                else
                    ++wc[nc];
            }
            nc = 0;
            state = OUT;
        }
        else
        {
            // at the start or in the middle of a word
            ++nc;
            state = IN;
        }

    // compute the biggest count in `wc`
    maxc = 0;
    for (i = 1; i < MAXWLEN; ++i)
        if (wc[i] > maxc)
            maxc = wc[i];

    // Print the histogram.
    // First, iterate over the lines; you can think of them as count levels.
    for (i = MAXHBAR; i >= 1; --i)
    {
        // iterate over the columns; i.e. the word lengths
        for (j = 1; j < MAXWLEN; ++j)
            // test whether the  count for this particular word  length (`j`) is
            // above the iterated level (`i`)
            if ((i == 1 && wc[j] > 0) || (MAXHBAR * wc[j] / maxc) >= i)
                printf("   *   ");
            else
                printf("       ");
        putchar('\n');
    }

    // print the lengths and counts
    for (i = 1; i < MAXWLEN; ++i)
        printf("%6d ", i);
    putchar('\n');
    for (i = 1; i < MAXWLEN; ++i)
        printf("%6d ", wc[i]);
    putchar('\n');

    // print the number of words which were too big for the histogram
    printf("There are %d words >= %d\n", overflow, MAXWLEN);

    return 0;
}
