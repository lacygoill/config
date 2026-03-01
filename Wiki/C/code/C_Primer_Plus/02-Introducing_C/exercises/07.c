// Purpose: Many studies  suggest that  smiling has  benefits.  Write  a program
// that produces the following output:
//
//     Smile!Smile!Smile!
//     Smile!Smile!
//     Smile!
//
// Have the  program define a function  that displays the string  "Smile!" once,
// and have the program use the function as often as needed.
//
// Reference: page 54 (paper) / 83 (ebook)

#include <stdio.h>
void smile(void);

    int
main(void)
{
    int i;

    for (i = 0; i < 3; ++i)
        smile();
    printf("\n");

    for (i = 0; i < 2; ++i)
        smile();

    printf("\n");
    smile();
    printf("\n");

    return 0;
}

    void
smile(void)
{
    printf("Smile!");
}
