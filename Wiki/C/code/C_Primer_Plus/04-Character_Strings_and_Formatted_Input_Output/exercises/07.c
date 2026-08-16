// Purpose: Write a  program that sets  a `double`  variable to `1.0/3.0`  and a
// type `float` variable to `1.0/3.0`.  Display each result three times – once
// showing four digits  to the right of  the decimal, once showing  12 digits to
// the right  of the decimal,  and once  showing 16 digits  to the right  of the
// decimal.  Also have  the program include `float.h` and display  the values of
// `FLT_DIG` and  `DBL_DIG`.  Are the  displayed values of  `1.0/3.0` consistent
// with these values?
//
// Reference: page 141 (paper) / 170 (ebook)

#include <stdio.h>
#include <float.h>

    int
main(void)
{
    double third_d = 1.0 / 3.0;
    float third_f = 1.0f / 3.0f;
    printf("%.4f %.4f\n", third_d, third_f);
    //     0.3333 0.3333
    printf("%.12f %.12f\n", third_d, third_f);
    //     0.333333333333 0.333333343267
    printf("%.16f %.16f\n", third_d, third_f);
    //     0.3333333333333333 0.3333333432674408

    printf("%d\n", FLT_DIG);
    //     6
    printf("%d\n", DBL_DIG);
    //     15

    // Yes, the  values are consistent  with `FLT_DIG` and `DBL_DIG`.   That is,
    // the  digits  stop  being  significant  after  `FLT_DIG`  digits  for  the
    // `float`s, and after `DBL_DIG` digits for the `double`s.

    return 0;
}
