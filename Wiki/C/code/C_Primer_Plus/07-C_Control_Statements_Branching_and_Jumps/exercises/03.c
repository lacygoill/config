// Purpose: Write a program that reads integers until 0 is entered.  After input
// terminates,  the program  should report  the  total number  of even  integers
// (excluding the 0) entered, the average  value of the even integers, the total
// number of odd integers entered, and the average value of the odd integers.
//
// Reference: page 296 (paper) / 325 (ebook)

#include <stdio.h>

    int
main(void)
{
    int num;
    int n_even = 0;
    int n_odd = 0;
    int sum_even = 0;
    int sum_odd = 0;

    printf("Enter some integers(0 to quit):\n");
    scanf("%d", &num);
    while (num != 0)
    {
        if ((num % 2) == 0)
        {
            ++n_even;
            sum_even += num;
        }
        else
        {
            ++n_odd;
            sum_odd += num;
        }
        scanf("%d", &num);
    }
    printf("There are %d even integers whose average is %d.\n",
            n_even, sum_even / n_even);
    printf("There are %d odd integers whose average is %d.\n",
            n_odd, sum_odd / n_odd);

    return 0;
}
