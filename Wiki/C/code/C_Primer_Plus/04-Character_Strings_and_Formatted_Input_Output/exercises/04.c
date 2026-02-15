// Purpose: Write a program that requests your height in inches and your name,
// and then displays the information in the following form:
//
//     Dabney, you are 6.208 feet tall
//
// Use  type `float`,  and use  `/` for  division.  If  you prefer,  request the
// height in centimeters and display it in meters.
//
// Reference: page 141 (paper) / 170 (ebook)

#include <stdio.h>

    int
main(void)
{
    float height;
    char name[40];

    printf("Enter your height in inches and your name: ");
    scanf("%f%s", &height, name);
    height /= 12;
    printf("%s, you are %.3f feet tall.\n", name, height);

    return 0;
}
