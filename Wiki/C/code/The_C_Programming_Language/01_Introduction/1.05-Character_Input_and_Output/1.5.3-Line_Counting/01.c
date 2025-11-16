// Purpose: Write a program counting the number of lines in its input.
// Reference: page 19 (paper) / 33 (ebook)

#include <stdio.h>

    int
main(void)
{
    int c, nl;

    nl = 0;
    // no need to surround `while`'s body  with braces, because it only contains
    // a single `if` statement
    while ((c = getchar()) != EOF)
        // The `if`  statement tests the  parenthesized condition; if  true, the
        // body is executed.  Here, we test  if the input character is a newline
        // so that  we can count  newlines.  Counting newlines is  equivalent to
        // counting lines  because the  standard library  ensures that  an input
        // text stream  appears as  a sequence  of lines,  each terminated  by a
        // newline.
        if (c == '\n')
        //    ^^ ^--^
        //    |  newline character constant
        //    operator "is equal to"
        //
        // A character written between single quotes represents an integer value
        // equal  to the  numerical  value  of the  character  in the  machine's
        // character set.
        //
        // For example, `'A'`  is a character constant whose value  in the ASCII
        // character set is  65.  `'A'` is to be preferred  over 65: its meaning
        // is obvious and independent of a particular character set.
        //
        // Escape sequences used in string constants are also legal in character
        // constants.  So,  `\n` stands for  the value of the  newline character
        // which is 10 in ASCII.
        //
        // Don't conflate `'\n'` with `"\n"`.   The former is a single character
        // whose value  is an  integer.  The  latter is  a string  constant that
        // happens to contain only one character.
            ++nl;

    printf("%d\n", nl);

    return 0;
}
