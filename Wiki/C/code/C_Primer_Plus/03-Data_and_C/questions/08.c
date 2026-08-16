// Purpose: Suppose a program begins with these declarations:
//
//     int imate = 2;
//     long shot = 53456;
//     char grade = 'A' ;
//     float log = 2.71828;
//
// Fill in the proper type specifiers in the following `printf()` statements:
//
//     printf("The odds against the %__ where %__ to 1.\n", imate, shot);
//     printf("A score of %__ is not an %__ grade.\n", log, grade);
//
// Reference: page 96 (paper) / 125 (ebook)
#include <stdio.h>

    int
main(void)
{
    int imate = 2;
    long shot = 53456;
    char grade = 'A' ;
    float log = 2.71828f;

    printf("The odds against the %d where %ld to 1.\n", imate, shot);
    printf("A score of %f is not an %c grade.\n", log, grade);

    return 0;
}
