// Purpose: Write a program that reads a set of text lines and prints the longest.{{{
//
// Here is a simple outline:
//
//     while (there's another line)
//         if (it's longer than the previous longest)
//             save it
//             save its length
//     print longest line
//}}}
// Reference: page 28 (paper) / 42 (ebook)

#include <stdio.h>

#define MAXLINE 1000    // maximum input line size

// There's no need to  specify the length of the array  because it's already set
// in `main()`:
//
//              v-------v
//     char line[MAXLINE];
//                    vv
int get_line(char line[]);
//  ^
// In the book,  they name the function `getline()`.  We  don't because it would
// conflict with an existing function from the standard library:
//
//     1.c:23:5: error: conflicting types for ‘getline’; have ‘int(char *)’
//        23 | int getline(char line[]);
//           |     ^~~~~~~
//     In file included from 1.c:13:
//     /usr/include/stdio.h:697:18: note: previous declaration of ‘getline’ with type
//     ‘__ssize_t(char ** restrict,  size_t * restrict,  FILE * restrict)’
//     {aka ‘long int(char ** restrict,  long unsigned int * restrict,  FILE * restrict)’}

void copy(char from[], char to[]);
// ^
// no value is returned

// print longest input line
    int
main(void)
{
    int len;    // current line length
    int max;    // maximum length seen so far

    // The purpose of supplying the size of  an array in a declaration is to set
    // aside storage.
    //       v-------v
    char line[MAXLINE];       // current input line
    char longest[MAXLINE];    // longest saved line

    max = 0;
    // In the book, they pass `MAXLINE` to `get_line()`.
    // We don't because it needlessly makes the code harder to read.
    // Besides, it gives an error:{{{
    //
    //     error: assuming signed overflow does not occur when changing X +- C1 cmp C2 to X cmp C2 -+ C1 [-Werror=strict-overflow]
    //     |     for (i = 0; i < (lim - 1) && (c = getchar()) != EOF && c != '\n'; ++i)
    //     |                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^~~~~~~~~~~~
    //
    // To  fix this,  you would  need  to declare  `i`  and `lim`  (name of  the
    // `get_line()`'s parameter used to pass `MAXLINE`) as unsigned integers.
    //}}}
    while ((len = get_line(line)) > 0)
        if (len > max)
        {
            max = len;
            copy(line, longest);
        }
    // there was a line
    if (max > 0)
        printf("%s", longest);
        //      ^^
        //      conversion specification expecting a string
    return 0;
}

// read a line into `s`; return the length of the line, or 0 if no input
    int
get_line(char s[])
{
    int c, i;

    // Wait.  Isn't there a risk that `i` overflows to `MAXLINE`?{{{
    //
    // No.  You're probably  thinking about the case where the  loop breaks when
    // `i` reaches `MAXLINE - 1`,  then `i` is incremented one last  time in the
    // next `if` block.  That can't happen.
    //
    // `c` can't be set to `\n` during the iteration where `i` is `MAXLINE - 1`.
    // Because in that  iteration, the loop breaks early,  before `getchar()` is
    // invoked.   So, at  most,  `c` can  be  set to  `\n`  during the  previous
    // iteration,  where  `i`  is  `MAXLINE - 2`.  But  if  that  happens,  then
    // –  again –  the  loop breaks  early (`c != \n`),  before  `i` can  be
    // incremented to `MAXLINE - 1`.
    //
    // IOW,  if  `i`  is incremented  in  the  next  `if`  block, it's  at  most
    // `MAXLINE - 2`, and it ends up with the final value `MAXLINE - 1`.
    //}}}
    //
    //                       we're going to append a NUL
    //                       vvv
    for (i = 0; i < (MAXLINE - 1) && (c = getchar()) != EOF && c != '\n'; ++i)
    //            ^
    //            not `<=`, because an array's index starts at 0
        s[i] = (char)c;
    if (c == '\n')
    {
        s[i] = (char)c;
        ++i;
    }
    // By convention,  C marks  the end of  a string of  characters with  a NUL.
    // Let's do  the same.   This will be  useful for `copy()`  to know  when it
    // should stop copying characters.
    s[i] = '\0';
    return i;
}

// copy `from` into `to`; assume `to` is big enough
    void
copy(char from[], char to[])
{
    int i = 0;
    // We  don't  check  for  overflow  here; we  already  did  in  `get_line()`
    // (`i < (MAXLINE - 1)`).
    //
    //                           not `\n`, because there's no guarantee
    //                           that `from` contains a newline;
    //                           it doesn't if it has MAXLINE characters or more
    //                           vv
    while ((to[i] = from[i]) != '\0')
        ++i;
}
