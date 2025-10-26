// Purpose: Write  a program  printing a  table of  Fahrenheit temperatures  and
// their Celsius equivalent.
// Reference: page 8 (paper) / 22 (ebook)

#include <stdio.h>

/* print Fahrenheit-Celsius table
   for fahr = 0, 20, ..., 300 */
    int
main(void)
{
    // declarations announce the properties of variables
    int fahr, celsius;
    int lower, upper, step;
    //^ ^-----------------^
    //|  list of variables
    //+ type name

    // assignment statements set variables to their initial values
    lower = 0;      // lower limit of temperature table
    upper = 300;    // upper limit
    step = 20;      // step size
    //       ^
    //       individual statements are terminated by semicolons

    fahr = lower;
    //     as long this test is true, `while` executes its body
    //     v-----------v
    while (fahr <= upper) {
        // Pitfall: We can't multiply by `5 / 9`.
        // It would be truncated to 0, and all temperatures would be reported as 0.
        celsius = 5 * (fahr - 32) / 9;
        printf("%d\t%d\n", fahr, celsius);
        fahr += step;
    }

    return 0;
}
