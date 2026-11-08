// Purpose: Write a program  that asks for your first name,  your last name, and
// then prints the names in the format `last, first`.
//
// Reference: page 140 (paper) / 169 (ebook)

#include <stdio.h>

    int
main(void)
{
    char first[40];
    char last[40];

    printf("Enter your first name: ");
    scanf("%s", first);
    printf("Enter your last name: ");
    scanf("%s", last);
    printf("%s, %s\n", last, first);

    return 0;
}
