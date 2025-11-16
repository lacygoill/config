// Purpose: Re-write the temperature converter program to get rid of "magic numbers".
// Reference: page 14 (paper) / 28 (ebook)

#include <stdio.h>

// We give  meaningful names  to our magic  numbers.  More  generally, `#define`
// lets us define a symbolic name/constant to be a given string of characters:
//
//     #define NAME replacement text
//
// Thereafter, any occurrence of `NAME` will be replaced by `replacement text`.
// By convention, `NAME`  should always be in uppercase, so  that it's easier to
// distinguish a symbolic constant from a variable.
//
// ---
//
// Notice that  a `#define`  line does not  end with a  semicolon (just  like an
// `#include` line).
#define LOWER 0
#define UPPER 300
#define STEP 20
//      ^--^
//      symbolic constant

    int
main(void)
{
    int fahr;

    //          magic numbers have been replaced with symbolic constants
    //          v---v          v---v          v--v
    for (fahr = LOWER; fahr <= UPPER; fahr += STEP)
        printf("%3d %6.1f\n", fahr, (5.0f / 9.0f) * ((float)fahr - 32.0f));

    return 0;
}
