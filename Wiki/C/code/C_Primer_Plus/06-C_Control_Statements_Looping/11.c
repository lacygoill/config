// Purpose: a counting for loop
// Reference: page 208 (paper) / 237 (ebook)

#include <stdio.h>

    int
main(void)
{
    const int NUMBER = 22;
    int count;

    // Note that each of the three  control expressions is a full expression, so
    // any  side  effects  in  a  control expression,  such  as  incrementing  a
    // variable, take place before the program evaluates another expression.
    for (count = 1; count <= NUMBER; count++)
        printf("Be my Valentine!\n");

    return 0;
}
