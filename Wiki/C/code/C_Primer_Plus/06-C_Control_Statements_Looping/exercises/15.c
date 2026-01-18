// Purpose: Write a program  that reads in a  line of input and  then prints the
// line in reverse order.  You can store the input in an array of `char`; assume
// that the  line is  no longer than  255 characters.  Recall  that you  can use
// `scanf()` with the  `%c` specifier to read  a character at a  time from input
// and that the  newline character (`\n`) is generated when  you press the Enter
// key.
//
// GCC Options: -Wno-strict-overflow
//
// Reference: page 243 (paper) / 272 (ebook)

#include <stdio.h>
#define SIZE 255

    int
main(void)
{
    char array[SIZE];
    int i = 0;

    printf("Enter a line: ");
    while (scanf("%c", &array[i]) == 1 && array[i] != '\n')
        i++;

    for (i--; i >= 0; i--)
        printf("%c", array[i]);
    printf("\n");

    return 0;
}
