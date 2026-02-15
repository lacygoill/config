// Purpose: Find out what your system does with integer overflow, floating-point
// overflow, and  floating-point underflow by using  experimental approach; that
// is, write  programs having these  problems. (You can check the  discussion in
// Chapter 4  of `limits.h`  and `float.h`  to get guidance  on the  largest and
// smallest values.)
//
// Reference: page 97 (paper) / 126 (ebook)

#include <stdio.h>
#include <limits.h>
#include <float.h>

    int
main(void)
{
    printf("%d\n", INT_MAX + 1);
    // -2147483648
    // ✘

    printf("%f\n", FLT_MAX * 2);
    // inf

    printf("%e\n", FLT_MIN * FLT_EPSILON / 2);
    // 0.000000e+00
    // ✘

    return 0;
}
