// Purpose: some floating-point combinations
// Reference: page 119 (paper) / 148 (ebook)

#include <stdio.h>

    int
main(void)
{
    const double RENT = 3852.99;  // const-style constant

    printf("*%f*\n", RENT);
    printf("*%e*\n", RENT);
    printf("*%4.2f*\n", RENT);
    printf("*%3.1f*\n", RENT);
    printf("*%10.3f*\n", RENT);
    printf("*%10.3E*\n", RENT);
    printf("*%+4.2f*\n", RENT);
    printf("*%010.2f*\n", RENT);
    //     *3852.990000*
    //     *3.852990e+03*
    //     *3852.99*
    //     *3853.0*
    //     *  3852.990*
    //     * 3.853E+03*
    //     *+3852.99*
    //     *0003852.99*

    return 0;
}
