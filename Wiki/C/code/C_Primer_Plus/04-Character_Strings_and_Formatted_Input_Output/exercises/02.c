// Purpose: Write a program that requests your first name and does the following with it:
//
//     a. Prints it enclosed in double quotation marks
//
//     b. Prints it in a field 20 characters wide, with the whole field in quotes
//        and the name at the right end of the field
//
//     c. Prints it at the left end of a field 20 characters wide, with the whole
//        field enclosed in quotes
//
//     d. Prints it in a field three characters wider than the name
//
// Reference: page 140 (paper) / 169 (ebook)

#include <stdio.h>
#include <string.h>

    int
main(void)
{
    char first[40];
    int length;

    printf("Enter your first name: ");
    scanf("%s", first);

    // a.
    printf("\"%s\"\n", first);

    // b.
    printf("\"%20s\"\n", first);

    // c.
    printf("\"%-20s\"\n", first);

    // d.
    length = (int)strlen(first);
    printf("%*s\n", length + 3, first);

    return 0;
}
