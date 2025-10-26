// Purpose: Formatted Printing
// Reference: page 36

#include <stdio.h>

    int
main(void)
{
    int age = 10;
    int height = 72;

    printf("I am %d years old.\n", age);
    //           ^^
    //           conversion specifier
    //
    //           The int argument is converted to signed decimal notation.
    //           `man 3 printf /DESCRIPTION/;/Conversion specifiers/;/^\s*d,`
    printf("I am %d inches tall.\n", height);

    return 0;
}
