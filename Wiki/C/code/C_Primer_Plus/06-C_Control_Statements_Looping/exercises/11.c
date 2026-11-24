// Purpose: Write  a program that  reads eight integers  into an array  and then
// prints them in reverse order.
//
// Reference: page 243 (paper) / 272 (ebook)

#include <stdio.h>

    int
main(void)
{
    int array[8];

    printf("Enter 8 integers\n");
    for (int i = 0; i < 8; i++)
    {
        scanf("%d", &array[i]);
    }

    for (int i = 7; i >= 0; i--)
    {
        printf("%d ", array[i]);
    }
    printf("\n");

    return 0;
}
