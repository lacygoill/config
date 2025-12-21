// Purpose: In the U.S. system  of volume measurements, a pint is  2 cups, a cup
// is  8 ounces,  an ounce  is  2 tablespoons,  and tablespoon  is 3  teaspoons.
// Write  a  program  that request  a  volume  in  cups  and that  displays  the
// equivalent volumes in pints, ounces,  tablespoons, and teaspoons.  Why does a
// floating-point  type make  more sense  for this  application than  an integer
// type?
//
// Reference: page 97 (paper) / 126 (ebook)

#include <stdio.h>

    int
main(void)
{
    float pints, cups, ounces, tablespoons, teaspoons;

    printf("Enter a volume in cups: ");
    scanf("%f", &cups);

    pints = cups / 2;
    ounces = cups * 8;
    tablespoons = ounces * 2;
    teaspoons = tablespoons * 3;

    printf("The equivalent volume in pints is: %.2f.\n", pints);
    printf("The equivalent volume in ounces is: %.2f.\n", ounces);
    printf("The equivalent volume in tablespoons is: %.2f.\n", tablespoons);
    printf("The equivalent volume in teaspoons is: %.2f.\n", teaspoons);

    return 0;
}
