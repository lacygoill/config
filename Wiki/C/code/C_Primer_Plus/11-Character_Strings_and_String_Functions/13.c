// Purpose: no!
// GCC Options: -Wno-unused-variable
// Reference: page 465 (paper) / 494 (ebook)

#include <stdio.h>

    int
main(void)
{
    char side_a[] = "Side A";
    char dont[] = {'W', 'O', 'W', '!'};
    char side_b[] = "Side B";

    puts(dont);   // `dont` is not a string

    return 0;
}
//     WOW!(匣�
//         ^--^
//         garbage
//
// Because  `dont` lacks  a  closing null  character,  it is  not  a string,  so
// `puts()` won't  know where to stop.   It will just keep  printing from memory
// following `dont`  until it  finds a  null somewhere.  To  ensure that  a null
// character is  not too  distant, the  program stores  `dont` between  two true
// strings.
