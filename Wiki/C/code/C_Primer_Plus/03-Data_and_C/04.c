// Purpose: more `printf()` properties
// GCC Options: -w
// Reference: page 70 (paper) / 99 (ebook)

#include <stdio.h>

    int
main(void)
{
    unsigned int un = 3000000000;  // system with 32-bit int
    short end = 200;
    long big = 65537;
    long long verybig = 12345678908642;

    printf("un = %u and not %d\n", un, un);
    //     un = 3000000000 and not -1294967296
    //
    // The unsigned value  `3000000000` and the signed  value `-1294967296` have
    // exactly the same  internal representation in memory on  our system.  This
    // behavior shows up with values larger than the maximum signed value.

    printf("end = %hd and %d\n", end, end);
    //     end = 200 and 200
    //
    // The  `short`  variable `end`  is  displayed  the  same whether  you  tell
    // `printf()` that `end` is a `short` (the `%hd` specifier) or an `int` (the
    // `%d` specifier).  That's  because C automatically expands  a type `short`
    // value  to a  type  `int` value  when  it's  passed as  an  argument to  a
    // function.

    printf("big = %ld and not %hd\n", big, big);
    //     big = 65537 and not 1
    //
    // The  value `65537`  expressed  in binary  format as  a  32-bit number  is
    // `00000000000000010000000000000001`.  Using the  `%hd` specifier persuades
    // `printf()` to look  at just the last 16 bits;  therefore, it displays the
    // value as `1`.

    printf("verybig = %lld and not %d\n", verybig, verybig);
    //     verybig = 12345678908642 and not 1942899938
    //
    // Similarly, the  final output line shows  the full value of  `verybig` and
    // then the  value stored in  the last 32 bits,  as viewed through  the `%d`
    // specifier.

    return 0;
}
