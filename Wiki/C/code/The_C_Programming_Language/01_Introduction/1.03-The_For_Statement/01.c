// Purpose: Re-write the temperature converter program using a `for` loop.
// Reference: page 13 (paper) / 27 (ebook)

#include <stdio.h>

    int
main(void)
{
    // this time, we declare `fahr` as an `int`
    int fahr;
    // `upper` and `step` only appear as constants (instead of variables)
    //                     vvv          vv
    for (fahr = 0; fahr <= 300; fahr += 20)
    //   ^------^  ^---------^  ^--------^
    //      |           |       increment step
    //      |      test/condition
    //   initialization
        printf("%3d %6.1f\n", fahr, (5.0f / 9.0f) * ((float)fahr - 32.0f));
        //                          ^-----------------------------------^
        //                          We compute the celsius temperature directly
        //                          inside `printf()`'s argument.
        //
        //                          More generally, in any context where it is permissible
        //                          to use the value of a variable of some type, we can
        //                          use a more complicated expression of that type.

    // NOTE: We didn't enclose the `for` loop's body inside braces.
    // They're only necessary if the body contains multiple statements.
    // Here, we only have 1.
    return 0;
}
