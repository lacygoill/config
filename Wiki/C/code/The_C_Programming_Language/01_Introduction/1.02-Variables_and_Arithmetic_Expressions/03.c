// Purpose: Right-align the temperatures in the output of the previous program.
// Also, use floating-point arithmetic to get more accurate results.
// Reference: page 11 (paper) / 25 (ebook)

#include <stdio.h>

    int
main(void)
{
    // now, we declare `fahr` and `celsius` as floats
    float fahr, celsius;
    int lower, upper, step;

    lower = 0;
    upper = 300;
    step = 20;

    //     need to cast `lower` as a float
    //     v-----v
    fahr = (float)lower;
    while (fahr <= upper) {
        //        the formula can now be written in a more natural way
        //        v---------v
        celsius = 5.0f / 9.0f * (fahr - 32.0f);
        //        precisions
        //        vv   vv
        printf("%3.0f%6.1f\n", fahr, celsius);
        //       ^    ^
        // we specify  a width,  so that the  temperatures are  right-aligned in
        // their fields
        fahr += (float)step;
        //      ^-----^
        //      need to cast `step` as a float
    }

    return 0;
}
