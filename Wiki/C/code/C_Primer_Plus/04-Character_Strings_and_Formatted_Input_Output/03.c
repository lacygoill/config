// Purpose: difference between `sizeof()` and `strlen()`
// Reference: page 104 (paper) / 133 (ebook)

#include <stdio.h>
#include <string.h>
#define PRAISE "You are an extraordinary being."

    int
main(void)
{
    char name[40];

    printf("What's your name? ");
    scanf("%s", name);
    printf("Hello, %s. %s\n", name, PRAISE);

    // `strlen(name)`  counts  the  number   of  characters  in  `name`.   OTOH,
    // `sizeof(name)` counts the number of bytes allocated to `name` (here 40).
    // So, the two values can be very different.
    printf("Your name of %zd letters occupies %zd memory cells.\n",
            strlen(name), sizeof(name));

    // This time, `strlen()` and `sizeof()` almost agree.
    // `sizeof()` is just 1 bigger than `strlen()` (because of NUL).
    // The program  didn't tell  the computer  how much memory  to set  aside to
    // store `PRAISE`.   It had to  count the  number of characters  between the
    // double quotes itself.
    printf("The phrase of praise has %zd letters ",
            strlen(PRAISE));
    printf("and occupies %zd memory cells.\n", sizeof(PRAISE));

    return 0;
}
