// Purpose: Write a program that produces the following output:
//
//     For he's a jolly good fellow!
//     For he's a jolly good fellow!
//     For he's a jolly good fellow!
//     Which nobody can deny!
//
// Have the program use two user-defined  functions in addition to `main()`: one
// named `jolly()` that  prints the "jolly good" message once,  and one `deny()`
// that prints the final line once.
//
// Reference: page 53 (paper) / 82 (ebook)

#include <stdio.h>

void jolly(void);
void deny(void);

    int
main(void)
{
    int i;
    for (i = 0; i < 3; ++i)
        jolly();
    deny();
    return 0;
}

    void
jolly(void)
{
    printf("For he's a jolly good fellow!\n");
}

    void
deny(void)
{
    printf("Which nobody can deny!\n");
}
