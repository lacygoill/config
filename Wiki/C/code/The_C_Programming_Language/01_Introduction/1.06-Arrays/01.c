// Purpose: Write a program counting the number of occurrences of each digit, of
// white space characters, and of all other characters.
// Reference: page 22 (paper) / 36 (ebook)

#include <stdio.h>

    int
main(void)
{
    int c, i, nwhite, nother;
    // Declare that `ndigit` is an array of  10 integers.  We'll use it to store
    // the counts of digits (more readable than introducing 10 variables).
    int ndigit[10];
    //^       ^--^

    nwhite = nother = 0;
    // initialize array members
    for (i = 0; i < 10; ++i)
    //       ^
    // array subscripts always start at 0
        ndigit[i] = 0;
        //     ^
        // a  subscript  can  be  any  expression  (integer  variables,  integer
        // constants, ...)

    while((c = getchar()) != EOF)
        // test whether the input character is a digit
        //  v------------------v
        if ('0' <= c && c <= '9')
            ++ndigit[c - '0'];
            //       ^-----^
            // Numeric value of `c`.
            //
            // This works only if `'0'`,  ..., `'9'` have consecutive increasing
            // values.  Fortunately, this is true for all character sets.
            //
            // By  definition,  `char`s  are  just  small  integers,  so  `char`
            // variables (like `c`) and constants  (like `'0'`) are identical to
            // `int`s in arithmetic expressions.
        else if (c == ' ' || c == '\t' || c == '\n')
            ++nwhite;
        // The pattern:
        //
        //     if (condition₁)
        //         statement₁
        //     else if (condition₂)
        //         statement₂
        //     ...
        //         ...
        //     else
        //         statementₙ
        //
        // expresses a multi-way decision.
        // The  `condition`s are  evaluated in  order  from the  top until  some
        // `condition` is satisfied; at that point the corresponding `statement`
        // is executed, and the entire construction is finished.
        // Any `statement` can be several statements enclosed in braces.
        // If none  of the  conditions is satisfied,  the `statement`  after the
        // final `else`  is executed  if it  is present.   If absent,  no action
        // takes place.
        else
            ++nother;

    printf("digits =");
    for (i = 0; i < 10; ++i)
        printf(" %d", ndigit[i]);

    printf(", white space: %d, other: %d\n", nwhite, nother);

    return 0;
}
