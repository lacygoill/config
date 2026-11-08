// Purpose: joins two strings, check size first
// Reference: page 473 (paper) / 502 (ebook)

#include <stdio.h>
#include <string.h>
#define SIZE 30
#define BUGSIZE 13
char * s_gets(char * st, int n);

    int
main(void)
{
    char flower[SIZE];
    char addon[] = "s smell like old shoes.";
    char bug[BUGSIZE];
    unsigned int available;

    puts("What is your favorite flower?");
    s_gets(flower, SIZE);
    // Before  calling `strcat()`,  we make  sure  there's enough  space in  the
    // `flower` array for `addon` and for a trailing null.
    if ((strlen(flower) + strlen(addon) + 1) <= SIZE)
        strcat(flower, addon);
        // --^
    puts(flower);

    puts("What is your favorite bug?");
    s_gets(bug, BUGSIZE);

    // `bug` is  the actual input string  and its size can't  go beyond BUGSIZE.
    // So,  the available  space  is `BUGSIZE  - strlen(bug)  - 1`  (-1 for  the
    // trailing null).
    available = (unsigned int)BUGSIZE - (unsigned int)strlen(bug) - 1;

    // ---v
    strncat(bug, addon, available);
    //                  ^-------^
    // maximum number of characters to add.
    // For example, if  `available` is 13, `strncat()` will add  the contents of
    // `addon` to `bugs`,  stopping when it reaches 13  additional characters or
    // the null character, whichever comes first.
    puts(bug);

    return 0;
}

    char *
s_gets(char * st, int n)
{
    char * ret_val;
    int i = 0;

    ret_val = fgets(st, n, stdin);
    if (ret_val)
    {
        while (st[i] != '\n' && st[i] != '\0')
            i++;
        if (st[i] == '\n')
            st[i] = '\0';
        else
            while (getchar() != '\n')
                continue;
    }
    return ret_val;
}

//     What is your favorite flower?
//     Rose
//     Roses smell like old shoes.
//     What is your favorite bug?
//     Aphid
//     Aphids smell
