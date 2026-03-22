// Purpose: uses a `switch` statement
// Reference: page 280 (paper) / 309 (ebook)

#include <stdio.h>
#include <ctype.h>

    int
main(void)
{
    int ch;

    printf("Give me a letter of the alphabet, and I will give ");
    printf("an animal name\nbeginning with that letter.\n");
    printf("Please type in a letter; type # to end my act.\n");

    while ((ch = getchar()) != '#')
    {
        if (ch == '\n')
            continue;
        if (islower(ch))  // lowercase only
            switch (ch)
            {
                case 'a' :
                    printf("argali, a wild sheep of Asia\n");
                    break;
                case 'b' :
                    printf("babirusa, a wild pig of Malay\n");
                    break;
                case 'c' :
                    printf("coati, racoonlike mammal\n");
                    break;
                case 'd' :
                    printf("desman, aquatic, molelike critter\n");
                    break;
                case 'e' :
                    printf("echidna, the spiny anteater\n");
                    break;
                case 'f' :
                    printf("fisher, brownish marten\n");
                    break;
                default :
                    printf("That's a stumper!");
                          // end of switch
            }
        else
            printf("I recognize only lowercase letters.\n");
        while (getchar() != '\n')
            continue;     // skip rest of input line
        printf("Please type another letter or a #.\n");
                          // `while` loop end
    }
    printf("Bye!\n");

    return 0;
}
