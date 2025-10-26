// Purpose: Dust Off That Compiler
// Reference: page 29

#include <stdio.h>
// --------------^
// import header file `stdio.h`

/* This is a comment. */

    // return type
    //v
    int
main(int argc, char *argv[])
//   ^------^  ^----------^
//   argument count  |
//             pointer to an array of character strings
{
    int distance = 100;

    // this is also a comment
    printf("You are %d miles away.\n", distance);

    printf("\nfive\n");
    printf("more\n");
    printf("lines\n");
    printf("of\n");
    printf("text\n");

    return 0;
}
