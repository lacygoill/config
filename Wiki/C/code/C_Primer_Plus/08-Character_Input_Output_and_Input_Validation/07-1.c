// Purpose: get long integer (validate input)
// Reference: page 318 (paper) / 347 (ebook)

#include <stdio.h>

long get_long(void);

    int
main(void)
{
    long n = get_long();
    printf("You typed %ld.\n", n);
    return 0;
}

    long
get_long(void)
{
    long input;
    int ch;

    while (scanf("%ld", &input) != 1)
    {
        while((ch = getchar()) != '\n')
            putchar(ch);  // dispose of bad input
        printf(" is not an integer.\nPlease enter an ");
        printf("integer value, such as 25, -178, or 3: ");
    }

    return input;
}
