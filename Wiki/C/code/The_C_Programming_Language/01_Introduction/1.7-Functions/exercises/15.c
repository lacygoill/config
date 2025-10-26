// Purpose: Rewrite the temperature  conversion program of Section 1.2  to use a
// function for conversion.
// Reference: page 27 (paper) / 41 (ebook)

#include <stdio.h>

// function prototype for our conversion function `fahr2celsius()`
float fahr2celsius(float temp);

    int
main(void)
{
    float fahr, celsius;
    int lower, upper, step;

    lower = 0;
    upper = 300;
    step = 20;

    fahr = (float)lower;
    while (fahr <= upper) {
        //        here, we call our new `fahr2celsius()` function
        //        v----------v
        celsius = fahr2celsius(fahr);
        printf("%3.0f%6.1f\n", fahr, celsius);
        fahr += (float)step;
    }

    return 0;
}

    float
fahr2celsius(float temp)
{
    return 5.0f / 9.0f * (temp - 32.0f);
}
