// Purpose: when to use `&`
// Reference: page 128 (paper) / 157 (ebook)

#include <stdio.h>

    int
main(void)
{
    int age;
    float assets;
    char pet[30];

    printf("Enter your age, assets, and favorite pet.\n");

    // use `&` for variables
    //             v     v
    scanf("%d %f", &age, &assets);

    // do *not* use `&` for arrays
    scanf("%s", pet);

    printf("%d $%.2f %s\n", age, assets, pet);

    return 0;
}
