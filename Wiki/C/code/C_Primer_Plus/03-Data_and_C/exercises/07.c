// Purpose: There are 2.54  centimeters to the inch.  Write a  program that asks
// you  to  enter  your height  in  inches  and  then  displays your  height  in
// centimeters.   Or, if  you  prefer, ask  for the  height  in centimeters  and
// convert that to inches.
//
// Reference: page 97 (paper) / 126 (ebook)

#include <stdio.h>

    int
main(void)
{
    float inches;

    printf("Enter your height in inches: ");
    scanf("%f", &inches);
    printf("Your height in centimeters is: %.0f\n", inches * 2.54f);

    return 0;
}
