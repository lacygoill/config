// Purpose: Write a program counting lines, words, and characters.
// Reference: page 20 (paper) / 34 (ebook)

#include <stdio.h>

#define OUT 0
#define IN 1

    int
main(void)
{
    int c, nl, nw, nc, state;

    // `state` records whether we're in a word or not.
    // Initially, we're not, so `state` is assigned `OUT`.
    // As always, we prefer symbolic constants over magic numbers.
    state = OUT;

    // This  assigns `0`  to  the  variables `nl`,  `nw`,  and  `nc`.  It  works
    // because an  assignment is an  expression, and  the `=` operator  is right
    // associative.  So, this expression is equivalent to:
    //
    //     nl = (nw = (nc = 0))
    nl = nw = nc = 0;

    while ((c = getchar()) != EOF)
    {
        ++nc;
        if (c == '\n')
            ++nl;
        // There is a corresponding operator `&&` for AND.{{{
        //
        // Its precedence is just higher than `||`.
        // Both are left-associative.
        //
        // ---
        //
        // The evaluation stops as soon as the truth or falsehood of the overall
        // expression is known.
        //}}}
        //           logical OR
        //           vv           vv
        if (c == ' ' || c == '\t' || c == '\n')
            state = OUT;
        // alternative if the condition part of the `if` statement is false
        else if (state == OUT)
        {
            state = IN;
            ++nw;
        }
    }

    printf("characters: %d, words: %d, lines: %d\n", nc, nw, nl);

    return 0;
}
