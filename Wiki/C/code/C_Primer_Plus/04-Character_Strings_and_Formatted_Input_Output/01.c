// Purpose: nosy, informative program
// Reference: page 100 (paper) / 129 (ebook)

#include <stdio.h>
#include <string.h>    // for `strlen()` prototype
#define DENSITY 62.4f  // human density in lbs per cu ft

    int
main(void)
{
    float weight, volume;
    // `strlen()`'s return type is `size_t`
    size_t size, letters;

    // `name` is an array of 40 chars.
    // Only 39 can hold characters, the last one is for NUL.
    char name[40];

    printf("Hi! What's your first name?\n");
    scanf("%s", name);
    //          ^
    // No `&` prefix  because the name of  an array is the address  of its first
    // element.  IOW, it's already a pointer.

    printf("%s, what's your weight in pounds?\n", name);
    scanf("%f", &weight);

    size = sizeof(name);
    letters = strlen(name);
    volume = weight / DENSITY;

    printf("Well, %s, your volume is %2.2f cubic feet.\n", name, volume);
    printf("Also, your first name has %zd letters,\n", letters);
    printf("and we have %zd bytes to store it.\n", size);

    return 0;
}
