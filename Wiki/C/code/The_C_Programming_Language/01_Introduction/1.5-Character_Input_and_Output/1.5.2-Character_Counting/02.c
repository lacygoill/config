// Purpose: Rewrite the previous  program using a `for` loop and  save `nc` as a
// `double` instead of a `long` (to cope with even bigger numbers).
// Reference: page 18 (paper) / 32 (ebook)

#include <stdio.h>

    int
main(void)
{
    double nc;

    // NOTE: If  the input  is empty  (i.e.  you press  `C-d` immediately),  the
    // program's output  is `0` which  is correct.  That's because  `for`'s (and
    // `while`'s) test is at  the top of the loop.  It's  important to make sure
    // that programs do reasonable things with boundary conditions.
    for (nc = 0; getchar() != EOF; ++nc)
        // There's nothing to do in the body because all the work is done in the
        // test and increments part.  Still,  the grammatical rules of C require
        // the body not to be empty.  Thus, we use the null statement `;`.
        ;

    printf("%.0f\n", nc);
    //       ^^
    //       discard the useless fractional part (`.000000`)

    return 0;
}
