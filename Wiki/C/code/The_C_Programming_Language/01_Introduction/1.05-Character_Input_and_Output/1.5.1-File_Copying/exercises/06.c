// Purpose: Verify that the expression `getchar() != EOF` is `0` or `1`.
// GCC Options: -Wno-parentheses
// Reference: page 17 (paper) / 31 (ebook)

#include <stdio.h>

    int
main(void)
{
    int c;

    while (c = getchar() != EOF)
        // As long as you don't press `C-d`, the output is:
        //
        //     1
        //     1
        //
        // Note  that   `1`  is  printed   twice,  because  terminal   input  is
        // line-buffered.  That is,  for the terminal to send your  input to the
        // program,  you have  to press  Enter.   That keypress  sends an  extra
        // newline to the program.
        printf("%d\n", c);
    // When you press `C-d`, the output is finally a single `0`.
    printf("%d - at EOF\n", c);
}
