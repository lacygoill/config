// Purpose: a counting while loop
// Reference: page 207 (paper) / 236 (ebook)

#include <stdio.h>

    int
main(void)
{
    const int NUMBER = 22;
    int count = 1;                     // initialization

    while (count <= NUMBER)            // test
    {
        printf("Be my Valentine!\n");  // action
        count++;                       // update count
    }

    return 0;
}
