// Purpose: enter up to 10 lines, type "quit" to quit
// Reference: page 479 (paper) / 508 (ebook)

#include <stdio.h>
#include <string.h>
#define SIZE 80
#define LIM 10
#define STOP "quit"
char * s_gets(char * st, int n);

    int
main(void)
{
    char input[LIM][SIZE];
    int ct = 0;

    printf("Enter up to %d lines (type quit to quit):\n", LIM);
    while (ct < LIM
            // quit when encountering EOF
            && s_gets(input[ct], SIZE) != NULL
            // quit when the user write "quit"
            && strcmp(input[ct], STOP) != 0
            // quit on a blank line
            && input[ct][0] != '\0')
        ct++;
    printf("%d strings entered\n", ct);

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
            while (getchar())
                continue;
    }
    return ret_val;
}
