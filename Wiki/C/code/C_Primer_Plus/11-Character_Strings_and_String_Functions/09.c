// Purpose: using `fgets()`
// Reference: page 459 (paper) / 488 (ebook)

#include <stdio.h>
#define STLEN 10

    int
main(void)
{
    char words[STLEN];
    int i;

    puts("Enter strings (empty line to quit):");
    while (fgets(words, STLEN, stdin) != NULL
            && words[0] != '\n')
    {
        i = 0;
        while (words[i] != '\n' && words[i] != '\0')
            i++;
        // `puts()` will add an extra newline, so we get rid of the input one to
        // avoid a blank  line.
        //
        // ---
        //
        // If  `words[i] == '\n'`, we've  reached  the end  of  the input.   The
        // system  uses  buffered  I/O.   This  means the  input  is  stored  in
        // temporary memory (the  buffer) until the Return key  is pressed; this
        // adds a newline character to the input  and sends the whole line on to
        // `fgets()`.  So, we don't need to discard the rest of the input; there
        // is none.
        if (words[i] == '\n')
            words[i] = '\0';
        // Even though  `words[i] = '\0'`, the  input is  not finished.   But we
        // don't  want `fgets()`  to process  that remaining  input in  the next
        // iteration.  So, we discard it with `getchar()`.
        //
        // Discarding  the   rest  of  the   line  keeps  the   read  statements
        // synchronized with the  keyboard input.  If the remainder  of the line
        // is left in  place, it becomes the input for  the next read statement.
        // This can,  for example, cause the  program to crash if  the next read
        // statement is looking for a type `double` value.
        //
        // ---
        //
        // You might wonder how `words[i]` could  be the null character.  It can
        // happen if the  input is equal or longer than  `STLEN`.  In that case,
        // `fgets()` splits the  input after `STLEN - 1` characters  and adds an
        // extra null character.
        //
        // ---
        //
        // This block has  a 2nd benefit.  If you  input `STLEN - 1` characters,
        // the loop would  terminate, because `fgets()` would  stop reading just
        // before the validating newline, making the first character in the next
        // iteration a newline (`&& words[0] != '\n'`).
        else
            while (getchar() != '\n')
                continue;
        puts(words);
    }
    puts("done");
    return 0;
}
//     Enter strings (empty line to quit):
//     This
//     This
//     program seems
//     program s
//     unwilling to accept long lines.
//     unwilling
//     But it doesn't get stuck on long
//     But it do
//     lines either.
//     lines eit
//
//     done
