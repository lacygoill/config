// Purpose: `strncpy()` demo
// Reference: page 485 (paper) / 514 (ebook)

#include <stdio.h>
#include <string.h>
#define SIZE 40
#define DSTSIZE 7
#define LIM 5
char * s_gets(char * st, int n);

    int
main(void)
{
    char qwords[LIM][DSTSIZE];
    char word[SIZE];
    int i = 0;

    printf("Enter %d words beginning with q:\n", LIM);
    while (i < LIM && s_gets(word, SIZE))
    {
        if (word[0] != 'q')
            printf("%s doesn't begin with q!\n", word);
        else
        {
            strncpy(qwords[i], word, DSTSIZE - 1);
            qwords[i][DSTSIZE - 1] = '\0';
            i++;
        }
    }
    puts("Here are the words accepted:");
    for (i = 0; i < LIM; i++)
        puts(qwords[i]);

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

//     Enter 5 words beginning with q:
//     quack
//     quadratic
//     quisling
//     quota
//     quagga
//     Here are the words accepted:
//     quack
//     quadra
//     quisli
//     quota
//     quagga
