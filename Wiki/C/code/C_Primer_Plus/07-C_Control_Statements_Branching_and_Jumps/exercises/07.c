// Purpose: Write a  program that requests the  hours worked in a  week and then
// prints the gross pay, the taxes, and the net pay.  Assume the following:
//
//     a. Basic pay rate = $10.00/hr
//     b. Overtime (in excess of 40 hours) = time and a half
//     c. Tax rate: 15% of the first $300
//                  20% of the next $150
//                  25% of the rest
//
// Use `#define` constants, and don’t worry if the example does not conform to
// current tax law.
//
// Reference: page 296 (paper) / 325 (ebook)

#include <stdio.h>

#define PAY_RATE 10.00f
#define OVERTIME 40
#define OVERTIME_RATE 1.5f
#define TAX_RATE1 0.15f
#define TAX_RATE2 0.20f
#define TAX_RATE3 0.25f
#define BREAK1 300
#define BREAK2 (300 + 150)
#define BASE1 (TAX_RATE1 * BREAK1)
#define BASE2 BASE1 + (TAX_RATE2 * (BREAK2 - BREAK1))

    int
main(void)
{
    float hours, gross_pay, taxes;

    printf("Enter the number of hours worked in a week.\n");
    scanf("%f", &hours);
    if (hours > OVERTIME)
        hours += (hours - OVERTIME) * OVERTIME_RATE;

    gross_pay = hours * PAY_RATE;

    if (gross_pay <= BREAK1)
        taxes = TAX_RATE1 * gross_pay;
    else if (gross_pay <= BREAK2)
        taxes = BASE1 + (TAX_RATE2 * (gross_pay - BREAK1));
    else
        taxes = BASE2 + (TAX_RATE3 * (gross_pay - BREAK2));

    printf("Gross pay is %.2f.\n", gross_pay);
    printf("Net pay is %.2f.\n", gross_pay - taxes);
    printf("Taxes are %.2f.\n", taxes);

    return 0;
}
