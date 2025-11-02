// Purpose: Rewrite the previous program in a more compact way.
// Reference: page 17 (paper) / 31 (ebook)

#include <stdio.h>

    int
main(void)
{
    int c;

    // `c = getchar()`: any assignment can be  used as an expression whose value
    // is the one of the LHS after the assignment.
    while ((c = getchar()) != EOF)
    //     ^             ^
    // We need  the parentheses, because the  precedence of `!=` is  higher than
    // that of `=`. Without, the operations would be wrongly grouped:
    //
    //     while (c = (getchar() != EOF))
    //
    // `c` would always be assigned `0` (when `c` is `EOF`) or `1` (when it's not).
        putchar(c);

    return 0;
}
