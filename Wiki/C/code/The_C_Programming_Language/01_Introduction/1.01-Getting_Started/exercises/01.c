// Purpose: Run the `"hello, world"` program on your system.
// Experiment with leaving out parts of  the program, to see what error messages
// you get.
// Reference: page 8 (paper) / 22 (ebook)

#include <stdio.h>

    int
main(void)
{
    //     printf("hello, world");
    //                         ^
    //                         ✘
    // The newline is missing.  This leaves the cursor at the end of the line.

    //     printf("hello, world\n")
    //                            ^
    //                            ✘
    //                            missing semicolon at the end of the statement
    //
    //     error: expected ‘;’ before ‘return’
    //         |     printf("hello, world\n")
    //         |                             ^
    //         |                             ;

    //     printf("hello, world\n')
    //                           ^
    //                           ✘
    //                           double quote mistyped as a single quote
    //
    //     error: missing terminating " character [-Werror]
    //         |         printf("hello, world\n');
    //         |                ^
    //     error: missing terminating " character
    //         |         printf("hello, world\n');
    //         |                ^~~~~~~~~~~~~~~~~~

    return 0;
}
