// Purpose: Write a  program that uses one  `printf()` call to print  your first
// name and last name one one line,  uses a second `printf()` call to print your
// first and  last names on  two separate lines, and  uses a pair  of `printf()`
// calls to print your first and last names on one line.  The output should look
// like this (but using your name):
//
//     Gustav Mahler ← First print statement
//     Gustav        ← Second print statement
//     Mahler        ← Still the second print statement
//     Gustav Mahler ← Third and fourth print statement
//
// Reference: page 53 (paper) / 82 (ebook)

#include <stdio.h>

    int
main(void)
{
    char first_name[] = "Gustav";
    char last_name[] = "Mahler";

    printf("%s %s\n", first_name, last_name);
    printf("%s\n%s\n", first_name, last_name);
    printf("%s", first_name);
    printf(" %s\n", last_name);
    return 0;
}
