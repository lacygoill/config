// Purpose: Assuming that each  of the following examples is part  of a complete
// program, what will each one print?
//
// Reference: page 138 (paper) / 167 (ebook)

#include <stdio.h>
#include <string.h>

    int
main(void)
{
    // a.
    printf("He sold the painting for $%2.2f.\n", 2.345e2);
    //     He sold the painting for $234.50

    // b.
    printf("%c%c%c\n", 'H', 105, '\41');
    //     Hi!

    // c.
    #define Q "His Hamlet was funny without being vulgar."
    printf("%s\nhas %zd characters.\n", Q, strlen(Q));
    //     His Hamlet was funny without being vulgar.
    //     has 42 characters.

    // d.
    printf("Is %2.2e the same as %2.2f?\n", 1201.0, 1201.0);
    //     Is 1.20e+03 the same as 1201.00?

    return 0;
}
