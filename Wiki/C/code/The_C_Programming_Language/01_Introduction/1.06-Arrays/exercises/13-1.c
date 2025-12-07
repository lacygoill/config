// Purpose: Write a program to print a histogram of the lengths of words in its input.{{{
//
// Make the bars horizontal.  Output example (obtained by piping
// `/usr/share/dict/words` to the program):
//
//         1 -    52 : *
//         2 -   373 : *
//         3 -  1165 : *
//         4 -  3569 : ***
//         5 -  7033 : ******
//         6 - 11732 : **********
//         7 - 15457 : **************
//         8 - 16433 : ***************
//         9 - 15037 : *************
//        10 - 12115 : ***********
//     There are 21368 words >= 11
//
// Set `MAXHBAR` as  the maximum length of  a bar, and `MAXWLEN`  as the maximum
// length of a word.
//
// Each  bar's  length should  be  scaled  so  that  the longest  bar  reaches
// `MAXHBAR`  characters, and  the other  bars  are proportional  to their  word
// counts relative  to the maximum.   For example, if the  longest bar is  15 in
// length and it represents 99 words, then a bar representing 33 words should be
// 5 in length (`15 * 33 / 99`).
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
    int c, i;
    int nc;             // number of characters in a word
    int state;          // flag: are we inside a word or not?
    int overflow;       // number of words longer than `MAXWLEN`
    int blen;           // length of a bar in the histogram
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

    // print the histogram
    blen = 0;
    for (i = 1; i < MAXWLEN; ++i)
    {
        // print the prefix (e.g. `3 -    57 : `) before the bar
        printf("%5d - %5d : ", i, wc[i]);
        if (wc[i] == 0)
            blen = 0;
        // if the count is too small, still print a single `*`
        else if ((blen = MAXHBAR * wc[i] / maxc) == 0)
            blen = 1;
        // print the bar
        while (blen > 0)
        {
            putchar('*');
            --blen;
        }
        putchar('\n');
    }

    // print the number of words which were too big for the histogram
    printf("There are %d words >= %d\n", overflow, MAXWLEN);

    return 0;
}
