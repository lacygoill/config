// Purpose: Write  a program  `entab` that  replaces  strings of  blanks by  the
// minimum number of tabs and blanks to achieve the same spacing.
//
// Reference: page 34 (paper) / 48 (ebook)

#include <stdio.h>

#define TABSTOP 8

    int
main(void)
{
    int c, pos, spaces, tabs;
    spaces = tabs = 0;
    for (pos = 1; (c = getchar()) != EOF; ++pos)
        if (c == ' ')
            // If we reach a tabstop, we should forget the previous spaces.{{{
            //
            // Because the tab can replace them:
            //
            //     // before
            //     xxx▫▫▫▫▫
            //        ^---^
            //     those spaces can be replaced by a single tab
            //
            //
            //     // after
            //     xxx<===>
            //}}}
            if ((pos % TABSTOP) == 0)
            {
                spaces = 0;
                ++tabs;
            }
            else
                ++spaces;
        else
        {
            if (c == '\n')
                pos = 0;
            // if we  find a tab,  we should –  again – forget  the previous
            // spaces
            else if (c == '\t')
            {
                spaces = 0;
                // And we should update the position to the next tabstop.
                // Wait.  Why do you update the position only here?{{{
                // What about this next block:
                //
                //     while (tabs > 0)
                //     {
                //         --tabs;
                //         putchar('\t');
                //     }
                //
                // Those tabs are merely meant  to replace existing spaces; they
                // don't change the position:
                //
                //     // before
                //     ▫▫▫▫▫▫▫▫
                //     12345678
                //            ^
                //            position
                //
                //     // after
                //     <======>
                //     12345678
                //            ^
                //            position
                //
                // Here, we don't replace existing  spaces; we write a brand new
                // tab; this time, the position changes:
                //
                //     // before
                //     xxx
                //     123
                //       ^
                //       position
                //
                //     // after
                //     xxx<===>
                //     12345678
                //            ^
                //            position
                //}}}
                // OK, but how did you get this expression?{{{
                //
                // We need a function which verifies this:
                //
                //     f(1) = 7
                //     f(2) = 6
                //     f(3) = 5
                //     f(4) = 4
                //     f(5) = 3
                //     f(6) = 2
                //     f(7) = 1
                //     f(8) = 0
                //     f(9) = 7
                //     f(10) = 6
                //     ...
                //
                // Instinctively, we think about:
                //
                //     g(n) = TABSTOP - n % TABSTOP
                //
                // This works,  except for multiple of  `TABSTOP`.  For example,
                // `g(8)` is `8`,  but we want `f(8)` to be  `0`.  For `g(8)` to
                // be `0`, we need to decrement `n`:
                //
                //     g(n) = TABSTOP - (n - 1) % TABSTOP
                //                         ^^^
                //
                // That gets  us pretty  close to `f(n)`,  except all  values of
                // `g(n)` are  now 1  above `f(n)`;  hence why  we also  need to
                // decrement the overall expression:
                //
                //     g(n) = TABSTOP - (n - 1) % TABSTOP - 1
                //                                        ^^^
                //}}}
                pos += TABSTOP - (pos - 1) % TABSTOP - 1;
            }
            for (; tabs > 0; --tabs)
                putchar('\t');
            while (; spaces > 0; --spaces)
                putchar(' ');
            putchar(c);
        }
}
