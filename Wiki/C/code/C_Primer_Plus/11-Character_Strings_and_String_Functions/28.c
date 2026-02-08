// Purpose: format a string
// GCC Options: -Wno-format-overflow
// Reference: page 488 (paper) / 517 (ebook)

#include <stdio.h>
#define MAX 20
char * s_gets(char * st, int n);

    int
main(void)
{
    char first[MAX];
    char last[MAX];
    char formal[2 * MAX + 10];
    double prize;

    puts("Enter your first name:");
    s_gets(first, MAX);
    puts("Enter your last name:");
    s_gets(last, MAX);
    puts("Enter your prize money:");
    scanf("%lf", &prize);
    sprintf(formal, "%s, %-19s: $%6.2f\n", last, first, prize);
    puts(formal);

    return 0;
}

    char *
s_gets(char * st, int n)
{
    int i = 0;
    char * ret_val = fgets(st, n, stdin);
    if (ret_val)
    {
        while (st[i] != '\n' && st[i] != '\0')
            i++;
        if (st[i] == '\n')
            st[i] = '\0';
        else
            while (getchar())
                continue;
    }
    return ret_val;
}

//     Enter your first name:
//     Annie
//     Enter your last name:
//     von Wurstkasse
//     Enter your prize money:
//     25000
//     von Wurstkasse, Annie              : $25000.00
