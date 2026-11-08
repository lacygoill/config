// Purpose: Write a program that reads a  single word into a character array and
// then prints the word backward.  Hint: Use  `strlen()` to compute the index of
// the last character in the array.
//
// GCC Options: -Wno-strict-overflow
//
// Reference: page 242 (paper) / 271 (ebook)

#include <stdio.h>
#include <string.h>

    int
main(void)
{
    char word[20];
    int len;

    printf("Enter a single word: ");
    scanf("%s", word);
    len = (int)strlen(word);

    for (int i = len - 1; i >= 0 ; i--)
        printf("%c", word[i]);

    printf("\n");

    return 0;
}
