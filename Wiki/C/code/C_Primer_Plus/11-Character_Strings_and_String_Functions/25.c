// Purpose: `strcpy()` demo
// Reference: page 482 (paper) / 511 (ebook)

#include <stdio.h>
#include <string.h>  // declares `strcpy()`
#define SIZE 40
#define LIM 5
char * s_gets(char * st, int n);

    int
main(void)
{
    char qwords[LIM][SIZE];
    char word[SIZE];
    int i = 0;

    printf("Enter %d words beginning with q:\n", LIM);
    while (i < LIM && s_gets(word, SIZE))
    {
        if (word[0] != 'q')
            printf("%s doesn't begin with q!\n", word);
        else
        {
            strcpy(qwords[i], word);
            // --^
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

//     Enter 5 words beginning with q:
//     quackery
//     quasar
//     quilt
//     quotient
//     no more
//     no more doesn't begin with q!
//     quiz
//     Here are the words accepted:
//     quackery
//     quasar
//     quilt
//     quotient
//     quiz
