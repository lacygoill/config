// Purpose: uses defined constants from limits.h and float.h
// Reference: page 111 (paper) / 140 (ebook)

#include <stdio.h>
#include <limits.h>
#include <float.h>

    int
main(void)
{
    printf("Some number limits for this system:\n");
    printf("Biggest int: %d\n", INT_MAX);
    printf("Smallest long long: %lld\n", LLONG_MIN);
    printf("One byte = %d bits on this system.\n", CHAR_BIT);
    printf("Largest double: %e\n", DBL_MAX);
    printf("Smallest precision = %d digits\n", FLT_DIG);
    printf("float epsilon = %e\n", FLT_EPSILON);
    //     Some number limits for this system:
    //     Biggest int: 2147483647
    //     Smallest long long: -9223372036854775808
    //     One byte = 8 bits on this system.
    //     Largest double: 1.797693e+308
    //     Smallest precision = 6 digits
    //     float epsilon = 1.192093e-07

    return 0;
}
