// Purpose: Make the  number you  assign to `universe_of_defects`  various sizes
// until you get a warning from the compiler.
// Reference: page 56

#include <stdio.h>

    int
main(void)
{
    // According to `/usr/include/limits.h`, this is  the biggest integer that a
    // `long` variable can hold:
    long universe_of_defects = 9223372036854775807L;
    //                                            ^
    // Beyond, for example if you add 1, you get a warning:
    //
    //     error: integer overflow in expression of type ‘long int’ results in ‘-9223372036854775808’
    //     long universe_of_defects = 9223372036854775807L + 1;
    //                                                     ^
    printf("%ld\n", universe_of_defects);

    return 0;
}
