// Reference: page 6 (paper) / 20 (ebook)

// include information about the standard input/output library
#include <stdio.h>

    // return type
    //v
    int
main(void)
// ^ ^--^
// | empty argument list
// function name; `main` is a special name: `main()` is called automatically
{
    // `\n`: Escape sequence representing the newline character.{{{
    //
    // When printed, it advances the output to the left margin
    // on the next line.
    //
    // ---
    //
    // Escape  sequences   provide  a  general  and   extensible  mechanism  for
    // representing hard-to-type  or invisible  characters.  For  example, `\t`,
    // `\b`, `\"`, and `\\` are provided for resp. tab, backspace, double quote,
    // and backslash.
    //
    // ---
    //
    // `printf()` never supplies  a newline automatically, so  several calls can
    // be used to build up an output line in stages.  For example, this:
    //
    //     printf("hello, ");
    //     printf("world");
    //     printf("\n");
    //
    // is equivalent to this:
    //
    //     printf("hello, world\n");
    //}}}
    // `printf(...)`: call the function `printf()` with only 1 argument: `"hello, world\n"`
    // `"hello world\n"`: character string or string constant
    printf("hello, world\n");    // <-- statements
    return 0;                    // <--
}    // <-- the statements of a function must be enclosed in braces
