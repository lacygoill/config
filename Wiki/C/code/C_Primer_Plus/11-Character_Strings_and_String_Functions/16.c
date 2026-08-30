// Purpose: user-defined output functions
// Reference: page 468 (paper) / 497 (ebook)

#include <stdio.h>
void put1(const char *);
int put2(const char *);

    int
main(void)
{
    put1("If I'd as much money");
    put1(" as I could spend,\n");
    printf("I count %d characters.\n",
            put2("I never would cry old chairs to mend."));

    return 0;
}

    void
put1(const char * string)
{
    while (*string)
        putchar(*string++);
}

    int
put2(const char * string)
{
    int count = 0;
    while (*string)
    {
        putchar(*string++);
        count++;
    }
    putchar('\n');

    return count;
}
//     If I'd as much money as I could spend,
//     I never would cry old chairs to mend.
//     I count 37 characters.
