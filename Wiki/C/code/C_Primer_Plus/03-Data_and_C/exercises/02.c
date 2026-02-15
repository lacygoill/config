// Purpose: Write a program that asks you to  enter an ASCII code value, such as
// 66, and then prints the character having that ASCII code.
//
// Reference: page 97 (paper) / 126 (ebook)

#include <stdio.h>

    int
main(void)
{
    int ch;

    printf("Enter an ASCII code value: ");
    scanf("%d", &ch);
    printf("You chose %c.\n", ch);

    return 0;
}
