// Purpose: Modify assumption `a.` in exercise 7  so that the program presents a
// menu of  pay rates from which  to choose.  Use  a `switch` to select  the pay
// rate.  The beginning of a run should look something like this:
//
//     *****************************************************************
//     Enter the number corresponding to the desired pay rate or action:
//     1) $8.75/hr                         2) $9.33/hr
//     3) $10.00/hr                        4) $11.20/hr
//     5) quit
//     *****************************************************************
//
// If choices  1 through 4  are selected, the  program should request  the hours
// worked.  The program  should recycle until 5 is entered.   If something other
// than choices 1 through 5 is entered,  the program should remind the user what
// the proper  choices are and then  recycle.  Use `#define`d constants  for the
// various earning rates and tax rates.
//
// Reference: page 297 (paper) / 326 (ebook)

#include <stdio.h>

#define OVERTIME 40
#define OVERTIME_RATE 1.5f
#define PAY_RATE1 8.75f
#define PAY_RATE2 9.33f
#define PAY_RATE3 10.00f
#define PAY_RATE4 11.20f
#define TAX_RATE1 0.15f
#define TAX_RATE2 0.20f
#define TAX_RATE3 0.25f
#define BREAK1 300
#define BREAK2 (300 + 150)
#define BASE1 (TAX_RATE1 * BREAK1)
#define BASE2 BASE1 + (TAX_RATE2 * (BREAK2 - BREAK1))

void print_menu(void);
void print_results(float pay_rate);

    int
main(void)
{
    int choice;

    print_menu();
    while (scanf("%d", &choice) == 1)
    {
        switch (choice)
        {
            case 1: print_results(PAY_RATE1); break;
            case 2: print_results(PAY_RATE2); break;
            case 3: print_results(PAY_RATE3); break;
            case 4: print_results(PAY_RATE4); break;
            case 5: return 0;
            default: printf("Please input right number.\n"); break;
        }
        print_menu();
    }
    return 0;
}

    void
print_menu(void)
{
    printf("*****************************************************************\n");
    printf("Enter the number corresponding to the desired pay rate or action:\n");
    printf("1) $8.75/hr                         2) $9.33/hr\n");
    printf("3) $10.00/hr                        4) $11.20/hr\n");
    printf("5) quit\n");
    printf("*****************************************************************\n");
}

    void
print_results(float pay_rate)
{
    float hours, gross_pay, taxes;

    printf("Enter the number of hours worked in a week.\n");
    scanf("%f", &hours);
    if (hours > OVERTIME)
        hours += (hours - OVERTIME) * OVERTIME_RATE;

    gross_pay = hours * pay_rate;

    if (gross_pay <= BREAK1)
        taxes = TAX_RATE1 * gross_pay;
    else if (gross_pay <= BREAK2)
        taxes = BASE1 + (TAX_RATE2 * (gross_pay - BREAK1));
    else
        taxes = BASE2 + (TAX_RATE3 * (gross_pay - BREAK2));

    printf("\nGross pay is %.2f.\n", gross_pay);
    printf("Net pay is %.2f.\n", gross_pay - taxes);
    printf("Taxes are %.2f.\n\n", taxes);
}
