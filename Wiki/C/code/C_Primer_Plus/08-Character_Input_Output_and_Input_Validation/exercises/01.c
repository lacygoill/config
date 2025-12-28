// Purpose: Devise a program  that counts the number of characters  in its input
// up to the end of file.
//
// Reference: page 332 (paper) / 361 (ebook)

#include <stdio.h>

    int
main(void)
{
    long count = 0;
    while (getchar() != EOF)
        count++;
    printf("The file has %ld characters.\n", count);
    return 0;
}
