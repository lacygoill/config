// Purpose: using `fgets()` and `fputs()`
// Reference: page 457 (paper) / 486 (ebook)

#include <stdio.h>
#define STLEN 10

    int
main(void)
{
    char words[STLEN];

    puts("Enter strings (empty line to quit):");
    while (fgets(words, STLEN, stdin) != NULL && words[0] != '\n')
        fputs(words, stdout);
    puts("Done.");

    return 0;
}
//     Enter strings (empty line to quit):
//     By the way, the gets() function
//     By the way, the gets() function
//     also returns a null pointer if it
//     also returns a null pointer if it
//     encounters end-of-file.
//     encounters end-of-file.
//
//     Done.
//
// Even though `STLEN` is 10, the  program has no problem processing input lines
// much  longer than  that.  `fgets()` reads  in  input `STLEN – 1`  (i.e., 9)
// characters at a time.  So it begins by reading “By the wa”, storing it as
// `By the wa\0`.  Then `fputs()`  displays this string and does  not advance to
// the  next output  line.  Next,  `fgets()` resumes  where it  left off  on the
// original  input,  that  is,  it  reads  “y, the ge”  and  stores  it  as
// `y, the ge\0`.  Then `fputs()`  displays it on the same line  it used before.
// Then `fgets()` resumes reading the input,  and so on, until all that’s left
// is “tion\n”; `fgets()` stores `tion\n\0`,  `fputs()` displays it, and the
// embedded newline character moves the cursor to the next line.
