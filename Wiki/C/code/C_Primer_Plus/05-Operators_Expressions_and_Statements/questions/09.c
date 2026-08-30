// Purpose: Modify the last program so that it prints the letters "a" through "g" instead.
// Reference: page 185 (paper) / 214 (ebook)

#include <stdio.h>

    int
main(void)
{
    int ch = 'a' - 1;

    while (++ch <= 'g')
        printf("%5c", ch);
    printf("\n");

    return 0;
}
