// Purpose: There are  approximately 3.156 *  10^7 seconds  in a year.   Write a
// program that  requests your  age in  years and  then displays  the equivalent
// number of seconds.
//
// Reference: page 97 (paper) / 126 (ebook)

#include <stdio.h>

    int
main(void)
{
    float seconds_in_year = 3.156e+07f;
    int age;

    printf("Enter your age in years: ");
    scanf("%d", &age);
    printf("The equivalent in seconds is: %.0f\n", seconds_in_year * (float)age);

    return 0;
}
