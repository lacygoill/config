// Purpose: watch your semicolons
// Reference: page 196 (paper) / 225 (ebook)
#include <stdio.h>

    int
main(void)
{
    int n = 0;
    while (n++ < 3);
    //             ^
    //             null statement
    //             the loop will run until `n` is 4, without doing anything else
        // this is not part of the loop
        printf("n is %d\n", n);
    printf("That's all this program does.\n");
    //     n is 4
    //     That's all this program does.

    return 0;
}
