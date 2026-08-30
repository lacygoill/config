// Purpose: Write a  program that  reads characters from  the standard  input to
// end-of-file.  For  each character, have  the program  report whether it  is a
// letter.   If it  is  a letter,  also  report its  numerical  location in  the
// alphabet.   For example,  c and  C  would both  be letter  3.  Incorporate  a
// function that  takes a  character as  an argument  and returns  the numerical
// location if the character is a letter and that returns -1 otherwise.
//
// Reference: page 381 (paper) / 410 (ebook)

#include <stdio.h>
#include <ctype.h>

int location(char ch);

    int
main(void)
{
    int ch;
    int code;
    printf("Input some text: ");
    while ((ch = getchar()) != EOF)
    {
        if ((code = location((char)ch)) != -1)
        {
            printf("%c is a letter.\n", ch);
            printf("Its location in the alphabet is %d.\n", code);
        }
    }
    return 0;
}

    int
location(char ch)
{
    if (isalpha(ch))
        return tolower(ch) - 'a' + 1;
    return - 1;
}
