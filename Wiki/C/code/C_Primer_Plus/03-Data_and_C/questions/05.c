// Purpose: Dottie Cawm has concocted an error-laden program.  Help her find the mistakes.
//
//     include <stdio.h>
//     main
//     (
//      float g; h;
//      float tax, rate;
//      g = e21;
//      tax = rate*g;
//     )
//
// Reference: page 95 (paper) / 124 (ebook)

#include <stdio.h>

    int
main(void)
{
    float amount, total;
    float tax, rate;

    rate = 0.08f;
    amount = 1.0e5;
    tax = rate * amount;
    total = amount + tax;

    printf("You owe $%.2f plus $%.2f in taxes for a total of $%.2f.\n", amount, tax, total);

    return 0;
}
