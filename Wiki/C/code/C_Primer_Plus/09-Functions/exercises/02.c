// Purpose: Devise  a  function  `chline(ch,i,j)`   that  prints  the  requested
// character in columns `i` through `j`.  Test it in a simple driver.
//
// Reference: page 380 (paper) / 409 (ebook)

#include <stdio.h>

void chline(char ch, int i, int j);

    int
main(void)
{
    char ch;
    int i, j;
    printf("Input the character you want to print: ");
    ch = (char)getchar();
    printf("Input the 2 columns: ");
    scanf("%d%d", &i, &j);
    chline(ch, i, j);
}

    void
chline(char ch, int i, int j)
{
    for (int n = 1; n < i; n++)
        putchar(' ');
    for (int n = i; n <= j; n++)
        putchar(ch);
}
