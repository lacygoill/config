// Purpose: Write a program to print the corresponding Celsius to Fahrenheit table.
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

    printf("Celsius  Fahr\n");
    celsius = (float)lower;
    while (celsius <= upper) {
        // We know that `celsius = 5/9 * (fahr - 32)` converts Fahrenheit into Celsius.
        // So the reverse is:
        //
        //     fahr = 9/ 5 * celsius + 32
        fahr = (9.0f / 5.0f) * celsius + 32.0f;
        printf("    %3.0f%6.1f\n", celsius, fahr);
        celsius += (float)step;
    }
}
