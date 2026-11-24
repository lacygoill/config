// Purpose: How would you print the values  of the variables `words` and `lines`
// so they appear in the following form:
//
//     There were 3020 words and 350 lines.
//
// Here, 3020 and 350 represent the values of the two variables.
//
// Reference: page 52 (paper) / 81 (ebook)

#include <stdio.h>

    int
main(void)
{
    int words = 3020;
    int lines = 350;

    printf("There were %d words and %d lines.\n", words, lines);

    return 0;
}
