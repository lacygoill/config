// Purpose: The ABC  Mail Order  Grocery sells artichokes  for $2.05  per pound,
// beets for $1.15  per pound, and carrots  for $1.09 per pound.  It  gives a 5%
// discount  for orders  of $100  or more  prior to  adding shipping  costs.  It
// charges  $6.50 shipping  and handling  for any  order of  5 pounds  or under,
// $14.00 shipping  and handling for orders  over 5 pounds and  under 20 pounds,
// and $14.00 plus $0.50 per pound for shipments of 20 pounds or more.
//
// Write a program that  uses a switch statement in a loop  such that a response
// of a lets  the user enter the  pounds of artichokes desired, b  the pounds of
// beets, c the  pounds of carrots, and  q allows the user to  exit the ordering
// process.  The  program should keep track  of cumulative totals.  That  is, if
// the user  enters 4 pounds of  beets and later  enters 5 pounds of  beets, the
// program should report 9 pounds of beets.
//
// The program then should compute the  total charges, the discount, if any, the
// shipping charges, and  the grand total.  The program then  should display all
// the purchase  information: the cost  per pound,  the pounds ordered,  and the
// cost for  that order  for each vegetable,  the total cost  of the  order, the
// discount (if there is  one), the shipping charge, and the  grand total of all
// the charges.
//
// Reference: page 297 (paper) / 326 (ebook)

#define ARTICHOKES 2.05f
#define BEETS 1.15f
#define CARROTS 1.09f
#define DISCOUNT 0.05f
#define DISCOUNT_LIMIT 100
#define BREAK1 5
#define BREAK2 20
#define CHARGES1 6.50f
#define CHARGES2 14.00f
#define CHARGES3 14.00f
#define RATE3 0.50f

#include <stdio.h>
#include <ctype.h>

void print_menu(void);

    int
main(void)
{
    int ch;
    float weight;
    float weight_artichokes;
    float weight_beets;
    float weight_carrots;
    float charges_artichokes;
    float charges_beets;
    float charges_carrots;
    float total_charges;
    float discount;
    float total_weight;
    float shipping_charges;
    float grand_total;

    weight_artichokes = weight_beets = weight_carrots = 0;

    print_menu();
    while ((ch = tolower(getchar())) != 'q')
    {
        switch(ch)
        {
            case 'a': printf("\nEnter the desired pounds of artichokes: ");
                      scanf("%f", &weight);
                      weight_artichokes += weight;
                      break;
            case 'b': printf("\nEnter the desired pounds of beets: ");
                      scanf("%f", &weight);
                      weight_beets += weight;
                      break;
            case 'c': printf("\nEnter the desired pounds of carrots: ");
                      scanf("%f", &weight);
                      weight_carrots += weight;
                      break;
            default: printf("\nPlease enter the right character.\n");
                     break;
        }

        // flush possible remaining input
        while (getchar() != '\n')
            continue;

        print_menu();
    }

    charges_artichokes = weight_artichokes * ARTICHOKES;
    charges_beets = weight_beets * BEETS;
    charges_carrots = weight_carrots * CARROTS;

    total_charges = charges_artichokes + charges_beets + charges_carrots;

    discount = total_charges >= DISCOUNT_LIMIT ? total_charges * DISCOUNT : 0;

    total_weight = weight_artichokes + weight_beets + weight_carrots;
    if (total_weight <= BREAK1)
        shipping_charges = CHARGES1;
    else if (total_weight <= BREAK2)
        shipping_charges = CHARGES2;
    else
        shipping_charges = CHARGES2 + (total_weight - BREAK2) * RATE3;

    grand_total = total_charges - discount + shipping_charges;
    if (weight_artichokes > 0)
        printf("You purchased %.2f pounds of artichokes ($%.2f/lbs) for a sum of $%.2f.\n",
                weight_artichokes, ARTICHOKES, charges_artichokes);
    if (weight_beets > 0)
        printf("You purchased %.2f pounds of beets ($%.2f/lbs) for a sum of $%.2f.\n",
                weight_beets, BEETS, charges_beets);
    if (weight_carrots > 0)
        printf("You purchased %.2f pounds of carrots ($%.2f/lbs) for a sum of $%.2f.\n",
                weight_carrots, CARROTS, charges_carrots);

    printf("The total cost of the order is: $%.2f\n", total_charges);
    if (discount > 0)
        printf("You benefit from a discount of: $%.2f\n", discount);
    printf("The shipping charges are: $%.2f\n", shipping_charges);
    printf("The grand total of all charges is: $%.2f\n", grand_total);

    return 0;
}

    void
print_menu(void)
{
    printf("\nPlease enter the vegetables you want to buy:\n");
    printf("a) artichokes $%.2f/lbs\n", ARTICHOKES);
    printf("b) beets $%.2f/lbs\n", BEETS);
    printf("c) carrots $%.2f/lbs\n", CARROTS);
    printf("q) quit\n");
}
