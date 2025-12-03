// Purpose: Go search online to find out what `unsigned` does.
// Reference: page 56

#include <stdio.h>

    int
main(void)
{
    // `unsigned` changes the range of possible values that a variable can hold.
    // From `[-2147483648, 2147483647]` to `[0, 4294967295U]`.
    unsigned n = 4294967295U;
    //                     ^
    return 0;
}
