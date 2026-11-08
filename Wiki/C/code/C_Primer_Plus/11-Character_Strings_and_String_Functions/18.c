// Purpose: joins two strings
// Reference: page 472 (paper) / 501 (ebook)

#include <stdio.h>
#include <string.h>    // for `strcat()`
#define SIZE 80
char * s_gets(char * st, int n);

    int
main(void)
{
    char flower[SIZE];
    char addon[] = "s smell like old shoes.";
    puts("What is your favorite flower?");
    if (s_gets(flower, SIZE))
    {
        strcat(flower, addon);
        puts(flower);
        puts(addon);
    }
    else
        puts("End of file encountered!");
    puts("bye");

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
//     wonderflower
//     wonderflowers smell like old shoes.
//     s smell like old shoes.
//     bye
//
// Notice that  `strcat()` did concatenate  `flower` and `addon`:
//
//     wonderflowers smell like old shoes.
//     ^----------^^---------------------^
//        flower            addon
//
// which changed `flower` while leaving `addon` unchanged:
//
//     s smell like old shoes.
