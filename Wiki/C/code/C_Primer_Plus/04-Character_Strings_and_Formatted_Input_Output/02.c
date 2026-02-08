// Purpose: uses an assortment of strings
// Reference: page 102 (paper) / 131 (ebook)

#include <stdio.h>
#define PRAISE "You are an extraordinary being."

    int
main(void)
{
    char name[40];

    printf("What's your name? ");
    // NOTE: `scanf()` stops reading at the first whitespace.
    // So, if you input `Angela Plains`, only `Angela` will be assigned to `name`.
    scanf("%s", name);
    printf("Hello, %s. %s\n", name, PRAISE);

    return 0;
}
