// Purpose: Write a  program that  asks the  user to enter  the number  of miles
// traveled and  the number  of gallons  of gasoline  consumed.  It  should then
// calculate and  display the miles-per-gallon  value, showing one place  to the
// right of the  decimal.  Next, using the  fact that one gallon  is about 3.785
// liters  and  one mile  is  about  1.609  kilometers,  it should  convert  the
// mile-per-gallon value to a liters-per-100km  value, the usual European way of
// expressing fuel consumption, and display the result, showing one place to the
// right  of the  decimal.   Note that  the U.S.  scheme  measures the  distance
// traveled per amount  of fuel (higher is better), whereas  the European scheme
// measures the  amount of fuel  per distance  (lower is better).   Use symbolic
// constants (using `const` or `#define`) for the two conversion factors.
//
// Reference: page 142 (paper) / 171 (ebook)

#include <stdio.h>

    int
main(void)
{
    float miles, gallons;
    const float MILE2KM = 1.609f;
    const float GALLON2LITER = 3.785f;

    printf("Enter the number of miles traveled and gallons consumed: ");
    scanf("%f%f", &miles, &gallons);

    printf("The mile-per-gallon value is: %.1f", miles / gallons);
    printf("The liters-per-100km value is: %.1f", (miles * MILE2KM) / (gallons * GALLON2LITER));

    return 0;
}
