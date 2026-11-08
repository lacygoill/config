// Purpose: Run Listing 4.1  again, but this time give your  first and last name
// when it asks you for your first name.  What happens?  Why?
//
// Only the first  name is stored in `name`, because  with `%s`, `scanf()` stops
// at the first whitespace (the last name  is separated from the first name by a
// whitespace).  Also,  the last  name remains  in the  input buffer,  which the
// second `scanf()` tries to read, but fails to, because it expects a float, not
// a string; that's why `weight` is assigned a wrong value.
//
// Reference: page 138 (paper) / 167 (ebook)

#include <stdio.h>
#include <string.h>
#define DENSITY 62.4f

    int
main(void)
{
    float weight, volume;
    size_t size, letters;
    char name[40];

    printf("Hi! What's your first name?\n");
    scanf("%s", name);
    printf("%s, what's your weight in pounds?\n", name);
    scanf("%f", &weight);
    size = sizeof(name);
    letters = strlen(name);
    volume = weight / DENSITY;
    printf("Well, %s, your volume is %2.2f cubic feet.\n",
            name, volume);
    printf("Also, your first name has %zd letters,\n",
            letters);
    printf("and we have %zd bytes to store it.\n", size);

    return 0;
}
