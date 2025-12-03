// Purpose: Test the range and size of basic data types.
// Reference: page 9 (paper) / 23 (ebook)

#include <float.h>
#include <limits.h>
#include <stdio.h>

// NOTE: Ranges and sizes are machine-dependent.

    int
main(void)
{
    // minimal and maximal values for an `int`
    printf("%d\n", INT_MIN);
    //     -2147483648
    printf("%d\n", INT_MAX);
    //     2147483647

    // minimal and maximal values for a `float`
    printf("%g\n", FLT_MIN);
    //     1.17549e-38
    printf("%g\n", FLT_MAX);
    //     3.40282e+38

    // In addition to `int`, and `float`, C provides these basic data types:
    //
    //     char = character - a single byte
    //     short = short integer
    //     long = long integer
    //     double = double-precision floating point

    // minimal and maximal values for a `char`
    printf("%d\n", CHAR_MIN);
    //     -128
    printf("%d\n", CHAR_MAX);
    //     127

    // minimal and maximal values for a `short`
    printf("%d\n", SHRT_MIN);
    //     -32768
    printf("%d\n", SHRT_MAX);
    //     32767

    // minimal and maximal values for a `long`
    printf("%ld\n", LONG_MIN);
    //     -9223372036854775808
    printf("%ld\n", LONG_MAX);
    //     9223372036854775807

    // minimal and maximal values for a `double`
    printf("%g\n", DBL_MIN);
    //     2.22507e-308
    printf("%g\n", DBL_MAX);
    //     1.79769e+308

    // size of these data types
    printf("%ld\n", sizeof(char));
    printf("%ld\n", sizeof(short));
    printf("%ld\n", sizeof(int));
    printf("%ld\n", sizeof(float));
    printf("%ld\n", sizeof(long));
    printf("%ld\n", sizeof(double));
    //     1
    //     2
    //     4
    //     4
    //     8
    //     8

    return 0;
}
