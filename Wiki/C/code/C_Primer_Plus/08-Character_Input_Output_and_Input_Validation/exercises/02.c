// Purpose: Write a  program that reads  input as  a stream of  characters until
// encountering EOF.  Have the program print  each input character and its ASCII
// decimal value.   Note that  characters preceding the  space character  in the
// ASCII sequence  are nonprinting  characters.  Treat  them specially.   If the
// nonprinting character  is a  newline or  tab, print  \n or  \t, respectively.
// Otherwise, use control-character notation.  For  instance, ASCII 1 is Ctrl+A,
// which can be displayed  as ^A.  Note that the ASCII value for  A is the value
// for  Ctrl+A plus  64.  A  similar relation  holds for  the other  nonprinting
// characters.  Print 10 pairs  per line, except start a fresh  line each time a
// newline  character  is encountered.   (Note: The  operating  system may  have
// special  interpretations  for some  control  characters  and keep  them  from
// reaching the program.)
//
// Reference: page 333 (paper) / 362 (ebook)

#include <stdio.h>

#define PAIRS 10
#define SPACE 32
#define CTRL 64

    int
main(void)
{
    int ch;
    int count = 0;
    while ((ch = getchar()) != EOF)
    {
        count++;

        if (ch >= SPACE)
            putchar(ch);
        else if (ch == '\n' || ch == '\t')
            printf("%s", ch == '\n' ? "\\n" : "\\t");
        else
            printf("^%c", ch + CTRL);
            //            ^-------^
            //            the ASCII value for A is the value for Ctrl+A plus 64
            //

        printf(":%-5d ", ch);

        // When we encounter  a newline, the exercise wants us  to start a fresh
        // line.  That requires `count` to be reset to 0, so that the next block
        // `putchar()` a newline, and so that  we start counting from 1 again on
        // the next line.
        if (ch == '\n')
            count = 0;

        // Warning: You need  to `putchar()`  the newline *after*  the `PAIRS`th
        // character has been printed.  That means  this block needs to be after
        // `count++`.
        if (count % PAIRS == 0)
            putchar('\n');
    }
}
