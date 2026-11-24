// Purpose: The  1988 United  States Federal  Tax Schedule  was the  simplest in
// recent times. It had four categories, and  each category had two rates.  Here
// is a summary (dollar amounts are taxable income):
//
//    ┌───────────────────┬─────────────────────────────────────────┐
//    │ Category          │ Tax                                     │
//    ├───────────────────┼─────────────────────────────────────────┤
//    │ Single            │ 15% of first $17,850 plus 28% of excess │
//    ├───────────────────┼─────────────────────────────────────────┤
//    │ Head of Household │ 15% of first $23,900 plus 28% of excess │
//    ├───────────────────┼─────────────────────────────────────────┤
//    │ Married, Joint    │ 15% of first $29,750 plus 28% of excess │
//    ├───────────────────┼─────────────────────────────────────────┤
//    │ Married, Separate │ 15% of first $14,875 plus 28% of excess │
//    └───────────────────┴─────────────────────────────────────────┘
//
// For example, a single wage earner with  a taxable income of $20,000 owes 0.15
// × $17,850 + 0.28 × ($20,000−$17,850).  Write a program that lets the user
// specify the tax category and the  taxable income and that then calculates the
// tax.  Use a loop so that the user can enter several tax cases.
//
// Reference: page 297 (paper) / 326 (ebook)

#define BREAK1 17850
#define BREAK2 23900
#define BREAK3 29750
#define BREAK4 14875
#define RATE 0.15f
#define EXCESS_RATE 0.28f

#include <stdio.h>

void print_menu(void);
void print_results(int brk);

    int
main(void)
{
    int category;
    print_menu();
    while (scanf("%d", &category) == 1)
    {
        switch (category)
        {
            case 1: print_results(BREAK1); break;
            case 2: print_results(BREAK2); break;
            case 3: print_results(BREAK3); break;
            case 4: print_results(BREAK4); break;
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
    printf("******************************************************\n");
    printf("Specify your tax category:\n");
    printf("1) Single                         2) Head of Household\n");
    printf("3) Married, Joint                 4) Married, Separate\n");
    printf("5) quit\n");
    printf("******************************************************\n");
}

    void
print_results(int brk)
{
    float income;
    float taxes;
    printf("Enter your taxable income: ");
    scanf("%f", &income);
    if (income <= brk)
        taxes = income * RATE;
    else
        taxes = (float)brk * RATE + (income - (float)brk) * EXCESS_RATE;
    printf("Your taxes are: %.2f\n\n", taxes);
}
