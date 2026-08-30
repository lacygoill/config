// Purpose: displays code number for a character
// Reference: page 76 (paper) / 105 (ebook)

#include <stdio.h>

    int
main(void)
{
    char ch;

    printf("Please enter a character.\n");
    scanf("%c", &ch);  // user inputs character
    printf("The code for %c is %d.\n", ch, ch);
    //                   ^^    ^^
    //                   |     print value as decimal integer
    //                   print value as character

    return 0;
}
