// Purpose: The mass of a single molecule of water is about 3.0*10^-23 grams.  A
// quart of water is  about 950 grams.  Write a program  that requests an amount
// of  water, in  quarts, and  displays the  number of  water molecules  in that
// amount.
//
// Reference: page 97 (paper) / 126 (ebook)

#include <stdio.h>

    int
main(void)
{
    float mass_molecule = 3.0e-23f;
    int grams_per_quart = 950;
    int quart;

    printf("Enter an amount of water in quarts: ");
    scanf("%d", &quart);
    double amount = (double)quart * (double)grams_per_quart / (double)mass_molecule;
    printf("There are %e molecules in that amount of water.\n", amount);

    return 0;
}
