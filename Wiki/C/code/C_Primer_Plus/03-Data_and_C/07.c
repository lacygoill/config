// Purpose: displays float value in two ways
// Reference: page 82 (paper) / 111 (ebook)

#include <stdio.h>

    int
main(void)
{
    float aboat = 32000.0;
    double abet = 2.14e9;
    long double dip = 5.32e-5;

    printf("%f can be written %e\n", aboat, aboat);
    //     32000.000000 can be written 3.200000e+04

    // next line requires C99 or later compliance
    printf("And it's a %a in hexadecimal, powers of 2 notation\n", aboat);
    //     And it's a 0x1.f4p+14 in hexadecimal, powers of 2 notation

    printf("%f can be written %e\n", abet, abet);
    //     2140000000.000000 can be written 2.140000e+09

    printf("%Lf can be written %Le\n", dip, dip);
    //     0.000053 can be written 5.320000e-05

    return 0;
}
