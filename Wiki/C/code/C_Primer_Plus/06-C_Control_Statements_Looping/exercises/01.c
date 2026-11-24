// Purpose: Write a  program that creates an  array with 26 elements  and stores
// the 26 lowercase letters in it.  Also have it show the array contents.
//
// Reference: page 241 (paper) / 270 (ebook)

#include <stdio.h>
#define MAX_LETTERS 25

    int
main(void)
{
    char letters[26];
    char ch;
    int i = 0;

    for (ch = 'a'; ch <= 'z'; ch++)
    {
        letters[i] = ch;
        i++;
    }

    for (i = 0; i <= MAX_LETTERS; i++)
    {
        printf("%c", letters[i]);
    }

    return 0;
}
