// Purpose: a simple C program pointing out some of the basic features of programming in C.
// Reference: page 28 (paper) / 57 (ebook)

#include <stdio.h>               // include a header file (C preprocessor directive)
// A header file may define constants or indicate the names of functions and how
// they should be used.  But the actual code for a function is in a library file
// of precompiled code, not in a header  file.  The linker takes care of finding
// the library code you need.

    int                          // Function's header; it returns an int.
main(void)                       // a C program always begins execution with the function called main()
//   ^--^
// here, main() doesn't take any argument
{                                // beginning of the body of the function
    int num;                     // Declaration statement: declare a variable called num of type int.
                                 // The trailing semicolon is part of the statement.
                                 // `int` is a C keyword identifying one of the basic C data types.
    num = 1;                     // assignment statement: assign a value to num
    //^
    // identifier

    printf("I am a simple ");    // function call to the printf() function
    printf("computer.\n");       // another function call to printf()
    //               ^^
    //               start a new line (i.e. move the cursor to the beginning of the next line)
    printf("My favorite number is %d because it is first.\n", num);
    //                            ^^
    //                            placeholder indicating where and in what form to print the value of num

    return 0;                    // you can omit the return statement in main(), but not in other functions;
                                 // so better be consistent, and not omit it
}                                // end of the function definition

// Braces can also be used to gather statements within a function into a unit or
// block.
