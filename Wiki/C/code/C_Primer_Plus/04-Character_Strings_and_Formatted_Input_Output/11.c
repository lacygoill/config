// Purpose: some mismatched integer conversions
// Reference: page 122 (paper) / 151 (ebook)

#include <stdio.h>
#define PAGES 336
#define WORDS 65618

    int
main(void)
{
    short num = PAGES;
    short mnum = -PAGES;

    printf("num as short and unsigned short:  %hd %hu\n", num, num);
    printf("-num as short and unsigned short:  %hd %hu\n", mnum, mnum);
    printf("num as int char: %d %c\n", num, num);
    printf("WORDS as int, short, and char: %d %hd %c\n", WORDS, WORDS, WORDS);
    //     num as short and unsigned short:  336 336
    //     -num as short and unsigned short:  -336 65200
    //     num as int char: 336 P
    //     WORDS as int, short, and char: 65618 82 R
    //
    // On the second line, why `65200`, and not `336`?{{{
    //
    // This results from the way  that `signed short int` values are represented
    // on our system.  First, they are 2 bytes in size.  Second, the system uses
    // a method  called the two's  complement to represent signed  integers.  In
    // this method, the numbers 0 to 32767 represent themselves, and the numbers
    // 32768 to 65535  represent negative numbers, with 65535  being −1, 65534
    // being −2, and so forth.  Therefore,  −336 is represented by 65536 −
    // 336, or  65200.  So,  internally, −336  is stored  as 65200.   When you
    // ask  for −336  as  a  `signed int`, `printf()`  gives  you −336  (the
    // translation of 65200).  But when you ask for −336 as an `unsigned int`,
    // `printf()` gives you 65200 (no translation).  Be wary!  One number can be
    // interpreted as two  different values.  The moral is: Don't  expect a `%u`
    // conversion to simply strip the sign from a number.
    //}}}
    // On the third line, why `P`?{{{
    //
    // On our  system, a `short int` is  2 bytes and  a `char` is 1  byte.  When
    // `printf()` prints 336  using `%c`, it looks  at only 1 byte out  of the 2
    // used to hold 336.  This truncation amounts to dividing the integer by 256
    // and keeping just the remainder.  In this case, the remainder is 80, which
    // is the ASCII value for the character `P`.
    //
    //             80 in binary ASCII 'P'
    //             v------v
    //     0000000101010000
    //     ^--------------^
    //      336 in binary
    //}}}
    // On the fourth line, why `82` (and `R`)?{{{
    //
    // We tried printing an integer  (65618) larger than the maximum `short int`
    // (32767)  allowed on  our system.   Again,  the computer  does its  modulo
    // thing.  The  number 65618,  because of  its size, is  stored as  a 4-byte
    // `int` value on our system.  When we print it using `%hd`, `printf()` uses
    // only the  last 2 bytes.   This corresponds  to using the  remainder after
    // dividing  by 65536.   In this  case, the  remainder is  82.  A  remainder
    // between 32767 and 65536 would be  printed as a negative number because of
    // the way negative numbers are stored.
    //
    // 82 is the ASCII value for the character `R`.
    //}}}

    return 0;
}
