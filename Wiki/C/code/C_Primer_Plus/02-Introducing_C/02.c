// Purpose: convert 2 fathoms to feet
// Reference: page 42 (paper) / 71 (ebook)

#include <stdio.h>

    int
main(void)
{
    // we can declare multiple variables into a single statement
    int feet, fathoms;

    fathoms = 2;
    feet = 6 * fathoms;
    printf("There are %d feet in %d fathoms!\n", feet, fathoms);
    printf("Yes, I said %d feet!\n", 6 * fathoms);
    //                               ^---------^
    //                               the argument doesn't have to be a variable;
    //                               it can be any expression of the right type

    return 0;
}
