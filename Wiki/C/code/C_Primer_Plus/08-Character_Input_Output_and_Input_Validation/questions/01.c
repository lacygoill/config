// Purpose: `putchar(getchar())`  is a  valid expression; what  does it  do?  Is
// `getchar(putchar())` also valid?
//
// Answer: `putchar(getchar())` is valid.  It simply echo'es the character input
// by the user. `getchar(putchar())` is  not valid, because `getchar()` does not
// accept any argument, and `putchar()` expects one.
//
// Reference: page 331 (paper) / 360 (ebook)
