// Purpose: It's find the error time!
//
//     define B booboo
//     define X 10
//     main(int)
//     {
//        int age;
//        char name;
//        printf("Please enter your first name.");
//        scanf("%s", name);
//        printf("All right, %c, what's your age?\n", name);
//        scanf("%f", age);
//        xp = age + X;
//        printf("That's a %s! You must be at least %d.\n", B, xp);
//        rerun 0;
//     }
//
// Reference: page 138 (paper) / 167 (ebook)

#include <stdio.h>

#define B "booboo"
#define X 10

    int
main(void)
{
    int age, xp;
    char name[40];

    printf("Please enter your first name.\n");
    scanf("%s", name);
    printf("All right, %s, what's your age?\n", name);
    scanf("%d", &age);
    xp = age + X;
    printf("That's a %s! You must be at least %d.\n", B, xp);

    return 0;
}
