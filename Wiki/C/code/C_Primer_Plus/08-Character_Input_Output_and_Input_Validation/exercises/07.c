// Purpose: Modify  Programming Exercise  8  from  Chapter 7  so  that the  menu
// choices are labeled by  characters instead of by numbers; use  q instead of 5
// as the cue to terminate input.
//
// Reference: page 333 (paper) / 362 (ebook)

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
char get_choice(void);
char get_first(void);

    int
main(void)
{
    int choice;

    print_menu();
    while ((choice = get_choice()) != 'q')
    {
        switch (choice)
        {
            case 'a': print_results(PAY_RATE1); break;
            case 'b': print_results(PAY_RATE2); break;
            case 'c': print_results(PAY_RATE3); break;
            case 'd': print_results(PAY_RATE4); break;
            case 'q': return 0;
            default: printf("Please input right letter.\n"); break;
        }
        print_menu();
        // We need to flush stdin here, because a previous `print_results()` can
        // invoke `scanf()`, which in turn can leave a newline in the input.
        while (getchar() != '\n')
            continue;
    }
    return 0;
}

    char
get_choice()
{
    int ch = getchar();
    while (getchar() != '\n')
        continue;
    return (char)ch;
}

    void
print_menu(void)
{
    printf("*****************************************************************\n");
    printf("Enter the number corresponding to the desired pay rate or action:\n");
    printf("a) $8.75/hr                         b) $9.33/hr\n");
    printf("c) $10.00/hr                        d) $11.20/hr\n");
    printf("q) quit\n");
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
