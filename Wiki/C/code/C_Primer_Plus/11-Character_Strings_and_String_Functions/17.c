// Purpose: try the string-shrinking function
// Reference: page 470 (paper) / 499 (ebook)

#include <stdio.h>
#include <string.h>    // for `strlen()`

void fit(char *, unsigned int);

    int
main(void)
{
    char mesg[] = "Things should be as simple as possible,"
    " but not simpler.";

    puts(mesg);
    fit(mesg, 38);
    puts(mesg);
    puts("Let's look at some more of the string.");
    puts(mesg + 39);
    // The expression `mesg + 39` is the address of `mesg[39]`, which is a space
    // character.  So `puts()` displays that  character and keeps going until it
    // runs into the original null character.

    return 0;
}

    void
fit(char *string, unsigned int size)
{
    if (strlen(string) > size)
        string[size] = '\0';
}
//     Things should be as simple as possible, but not simpler.
//     Things should be as simple as possible
//     Let's look at some more of the string.
//      but not simpler.
