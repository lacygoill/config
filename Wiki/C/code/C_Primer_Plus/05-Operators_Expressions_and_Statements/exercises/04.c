// Purpose: Write a program that asks the  user to enter a height in centimeters
// and  then  displays  the  height  in centimeters  and  in  feet  and  inches.
// Fractional centimeters and  inches should be allowed, and  the program should
// allow the  user to continue  entering heights  until a non-positive  value is
// entered.  A sample run should look like this:
//
//     Enter a height in centimeters: 182
//     182.0 cm = 5 feet, 11.7 inches
//     Enter a height in centimeters (<=0 to quit): 168.7
//     168.0 cm = 5 feet, 6.4 inches
//     Enter a height in centimeters (<=0 to quit): 0
//     bye
//
// Reference: page 187 (paper) / 216 (ebook)

#include <stdio.h>

#define CM_PER_FOOT 30.48f
#define CM_PER_INCH 2.54f

    int
main(void)
{
    int feet;
    float height, inches;
    printf("Enter a height in centimeters: ");
    scanf("%f", &height);
    while (height > 0)
    {
        feet = (int)(height / CM_PER_FOOT);
        inches = (height - (float)feet * CM_PER_FOOT) / CM_PER_INCH;
        printf("%.1f cm = %d feet, %.1f inches\n", height, feet, inches);
        printf("Enter a height in centimeters (<=0 to quit): ");
        scanf("%f", &height);
    }

    return 0;
}
