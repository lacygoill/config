// Purpose: using `fgets()` and `fputs()`
// Reference: page 456 (paper) / 485 (ebook)

#include <stdio.h>
#define STLEN 14

    int
main(void)
{
    char words[STLEN];

    puts("Enter a string, please.");
    fgets(words, STLEN, stdin);
    printf("Your string twice (puts(), then fputs()):\n");
    puts(words);
    fputs(words, stdout);

    puts("Enter another string, please.");
    fgets(words, STLEN, stdin);
    printf("Your string twice (puts(), then fputs()):\n");
    puts(words);
    fputs(words, stdout);

    puts("Done.");

    return 0;
}
//     Enter a string, please.
//     apple pie
//     Your string twice (puts(), then fputs()):
//     apple pie
//
//     apple pie
//     Enter another string, please.
//     strawberry shortcake
//     Your string twice (puts(), then fputs()):
//     strawberry sh
//     strawberry shDone.
//
// The first input, `apple pie`, is short  enough that `fgets()` reads the whole
// input  line  and stores  `apple pie\n\0`  in  the  array.  So  when  `puts()`
// displays the  string and adds  its own newline to  the output, it  produces a
// blank  output  line  after  `apple pie`.  Because  `fputs()`  doesn't  add  a
// newline, it doesn't produce a blank line.
//
// The second  input line,  `strawberry shortcake`, exceeds  the size  limit, so
// `fgets()` reads the  first 13 characters and stores  `strawberry sh\0` in the
// array.  Again, `puts()` adds a newline to the output and `fputs()` doesn't.
