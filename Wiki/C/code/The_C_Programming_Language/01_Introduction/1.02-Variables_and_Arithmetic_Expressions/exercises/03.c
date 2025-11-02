// Purpose: Modify the  temperature conversion program to print  a heading above
// the table.
// Reference: page 13 (paper) / 27 (ebook)

#include <stdio.h>

    int
main(void)
{
    float fahr, celsius;
    int lower, upper, step;

    lower = 0;
    upper = 300;
    step = 20;

    // we add a heading
    // ---------------------v
    printf("Fahr Celsius\n");
    fahr = (float)lower;
    while (fahr <= upper) {
        celsius = (5.0f / 9.0f) * (fahr - 32.0f);
        printf(" %3.0f  %6.1f\n", fahr, celsius);
        //      ^     ^^
        //      we add spaces for the temperatures to be aligned with the heading
        fahr += (float)step;
    }
}
