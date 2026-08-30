// Purpose: a program using two functions in one file
// Reference: page 44 (paper) / 73 (ebook)

#include <stdio.h>

// prototype (aka function declaration)
void butler(void);

// The usual C  practice is to list `main()` first  because it normally provides
// the basic framework for a program.
    int
main(void)
{
    printf("I will summon the butler function.\n");
    // invoke the `butler()` function
    butler();
    printf("Yes. Bring me some tea and writeable DVDs.\n");

    return 0;
}

    void
butler(void)
{
    printf("You rang sir?\n");
}
